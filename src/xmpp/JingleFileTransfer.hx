package xmpp;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import xmpp.Jingle;
import xmpp.JingleS5B;
import xmpp.JingleS5BNetwork;

/**
	A file, as described in a file transfer.
**/
typedef JingleFile = {
	/** Name of the file, without directory **/
	var ?name:String;

	/** Last modified time ([XEP-0082](https://xmpp.org/extensions/xep-0082.html) date time) **/
	var ?date:String;

	/** Human-readable description **/
	var ?desc:String;

	/** Media type, `application/octet-stream` if not set **/
	var ?mediaType:String;

	/** Size in bytes **/
	var ?size:Float;

	/** Ranged transfers are supported, optionally of the range starting at `offset` with `length` **/
	var ?range:{?offset:Float, ?length:Float};

	/** Hashes of the file content **/
	var ?hashes:Array<Hash>;
}

/**
	A hash ([XEP-0300](https://xmpp.org/extensions/xep-0300.html)), e.g. `{algo: "sha-256", value: <base64>}`.
**/
typedef Hash = {
	var algo:String;

	/** Base64 encoded hash value **/
	var value:String;
}

/**
	Options of a file transfer.
**/
typedef JingleFileTransferOptions = {
	/** Block size of in-band bytestreams: offered by the sender, the maximum accepted by the receiver **/
	var ?blockSize:Int;

	/** Use SOCKS5 bytestreams (with this network configuration) **/
	var ?s5b:JingleS5BConfig;

	/** Fall back to in-band bytestreams if no SOCKS5 connection can be established (sender, default `true`) **/
	var ?fallback:Bool;

	/** Called with the number of sent or received bytes **/
	var ?onProgress:(bytes:Int) -> Void;
}

/**
	Transfer files with Jingle.

	Files are offered by the sender (`sendFile`) and transferred with SOCKS5 bytestreams (`JingleS5B`, direct or
	through a proxy) or in-band bytestreams (`JingleIBB`, the fallback).
	The receiver accepts (`receiveFile`) or declines (`session.terminate(decline)`) the offer,
	verifies the size and the hash of the received data and terminates the session (`success` or `media-error`).

		jingle.onSessionInitiate = session -> {
			final file = JingleFileTransfer.getFileOffer(session);
			if (file == null)
				return session.terminate(unsupported_applications);
			JingleFileTransfer.receiveFile(session, (reason, data) -> trace(reason.condition, data?.length));
		}
		JingleFileTransfer.sendFile(jingle, 'juliet@example.com/balcony', {name: 'test.txt'}, bytes, reason -> trace(reason.condition));

	With SOCKS5 bytestreams (e.g. on nodejs):

		final s5b:JingleS5BConfig = {network: new JingleS5BNodeNetwork()};
		JingleFileTransfer.sendFile(jingle, peer, file, bytes, {s5b: s5b}, reason -> trace(reason.condition));
		JingleFileTransfer.receiveFile(session, {s5b: s5b}, (reason, data) -> {});

	Not implemented: file requests (the receiver initiates), ranged transfers, multiple files per session.

	[XEP-0234: Jingle File Transfer](https://xmpp.org/extensions/xep-0234.html)
**/
@xep(234)
class JingleFileTransfer {
	public static inline var XMLNS = "urn:xmpp:jingle:apps:file-transfer:5";
	public static inline var XMLNS_HASHES = "urn:xmpp:hashes:2";

	/** Features to advertise for service discovery **/
	public static final FEATURES = [XMLNS, JingleIBB.XMLNS, JingleS5B.XMLNS];

	static inline var CONTENT_NAME = "a-file-offer";

	/**
		Offer `data` as `file` to `peer` (a full jid) and send it once accepted.

		The data is sent with SOCKS5 bytestreams if `options.s5b` is set (falling back to in-band bytestreams if no
		connection can be established), otherwise with in-band bytestreams.
		The `size` and a `sha-256` hash are added to `file` if not set.
		`callback` is called once the session ended, with the reason: `success` if the receiver confirmed the transfer.
	**/
	@:noUsing
	public static function sendFile(jingle:Jingle, peer:String, file:JingleFile, data:Bytes, ?options:JingleFileTransferOptions,
			callback:(reason:JingleReasonInfo) -> Void):JingleSession {
		final options:JingleFileTransferOptions = options ?? {};
		final blockSize = options.blockSize ?? JingleIBB.DEFAULT_BLOCK_SIZE;
		final file = Reflect.copy(file);
		file.size ??= data.length;
		if (file.hashes == null || file.hashes.length == 0)
			file.hashes = [hash(data)];
		final content:JingleContent = {
			creator: initiator,
			name: CONTENT_NAME,
			senders: initiator,
			description: createDescription(file)
		};
		final session = jingle.createSession(peer);
		var s5b:Null<JingleS5B> = null;
		var ibbSid:Null<String> = null;
		session.onTerminate = reason -> {
			if (s5b != null)
				s5b.close();
			callback(reason);
		}
		// the receiver confirms the receipt of the file before terminating the session
		session.onInfo = payload -> payload.filter(e -> e.name == "received" && e.is(XMLNS)).length == payload.length;
		function sendIBB(sid:String, size:Int)
			JingleIBB.send(session, sid, size, data, options.onProgress, error -> {
				if (error != null)
					session.terminate(failed_transport, error.condition);
				// otherwise the receiver terminates the session after verifying the data
			});
		function fallback(reason:String) {
			if (session.state == ended)
				return;
			if (options.fallback == false) {
				session.terminate(connectivity_error, reason);
				return;
			}
			ibbSid = xmpp.Stream.makeRandomId();
			session.send(transport_replace, [
				{creator: initiator, name: CONTENT_NAME, transport: JingleIBB.createTransport(ibbSid, blockSize)}
			]);
		}
		session.onAction = (req, respond) -> {
			final c = req.contents.filter(c -> c.name == CONTENT_NAME)[0];
			final transport = (c == null) ? null : c.transport;
			switch req.action {
				case transport_info if (s5b != null && transport != null && transport.is(JingleS5B.XMLNS)):
					respond();
					s5b.handleInfo(transport);
				case transport_accept if (ibbSid != null):
					final ibb = JingleIBB.parseTransport(transport);
					if (ibb == null || ibb.sid != ibbSid) {
						respond(new xmpp.Stanza.Error(modify, bad_request));
						session.terminate(failed_transport);
						return;
					}
					respond();
					if (s5b != null)
						s5b.close();
					sendIBB(ibb.sid, Std.int(Math.min(blockSize, ibb.blockSize)));
				case transport_reject if (ibbSid != null):
					respond();
					session.terminate(failed_transport);
				case _:
					respond(new xmpp.Stanza.Error(cancel, feature_not_implemented));
			}
		}
		session.onAccept = contents -> {
			final accepted = contents.filter(c -> c.name == CONTENT_NAME)[0];
			final transport = (accepted == null) ? null : accepted.transport;
			if (s5b != null) {
				if (transport == null || !transport.is(JingleS5B.XMLNS)) {
					session.terminate(unsupported_transports);
					return;
				}
				s5b.onFailed = fallback;
				s5b.onReady = stream -> {
					var pos = 0;
					while (pos < data.length) {
						final len = Std.int(Math.min(65536, data.length - pos));
						stream.write(data.sub(pos, len));
						pos += len;
						if (options.onProgress != null)
							options.onProgress(pos);
					}
					// the receiver terminates the session after verifying the data
				}
				s5b.start(transport);
			} else {
				final ibb = JingleIBB.parseTransport(transport);
				if (ibb == null || ibb.sid != ibbSid) {
					session.terminate(unsupported_transports);
					return;
				}
				sendIBB(ibb.sid, Std.int(Math.min(blockSize, ibb.blockSize)));
			}
		};
		if (options.s5b != null) {
			s5b = new JingleS5B(session, CONTENT_NAME, initiator, options.s5b);
			s5b.prepare(null, () -> {
				content.transport = s5b.createTransport();
				session.initiate([content]);
			});
		} else {
			ibbSid = xmpp.Stream.makeRandomId();
			content.transport = JingleIBB.createTransport(ibbSid, blockSize);
			session.initiate([content]);
		}
		return session;
	}

	/**
		Returns the offered file of a session initiated by the peer, or `null` if the session is no file offer.
	**/
	@:noUsing
	public static function getFileOffer(session:JingleSession):Null<JingleFile> {
		final content = getFileContent(session);
		return (content == null) ? null : parseDescription(content.description);
	}

	/**
		Accept the file offer of `session` and receive the data.

		Offers with in-band bytestreams and SOCKS5 bytestreams are accepted; without `options.s5b`
		no SOCKS5 connection is attempted (the sender falls back to in-band bytestreams).
		`callback` is called once the session ended: with the reason `success` and the data if the transfer succeeded.
		The data is verified with the offered size and hashes (if supported, e.g. `sha-1` and `sha-256`).
	**/
	@:noUsing
	public static function receiveFile(session:JingleSession, ?options:JingleFileTransferOptions,
			callback:(reason:JingleReasonInfo, data:Null<Bytes>) -> Void) {
		final options:JingleFileTransferOptions = options ?? {};
		final maxBlockSize = options.blockSize ?? JingleIBB.MAX_BLOCK_SIZE;
		final content = getFileContent(session);
		final file = (content == null) ? null : parseDescription(content.description);
		var data:Null<Bytes> = null;
		var s5b:Null<JingleS5B> = null;
		session.onTerminate = reason -> {
			if (s5b != null)
				s5b.close();
			callback(reason, (reason.condition == success) ? data : null);
		}
		if (file == null) {
			session.terminate(unsupported_applications);
			return;
		}
		function complete(error:Null<xmpp.Stanza.Error>, received:Null<Bytes>) {
			if (session.state == ended)
				return;
			if (error != null) {
				session.terminate(failed_transport, error.condition);
				return;
			}
			if (file.size != null && received.length != file.size) {
				session.terminate(media_error, 'size mismatch');
				return;
			}
			if (file.hashes != null && verify(received, file.hashes) == false) {
				session.terminate(media_error, 'hash mismatch');
				return;
			}
			data = received;
			session.info([createReceived(content)]);
			session.terminate(success);
		}
		function accept(transport:XML)
			session.accept([
				{
					creator: content.creator,
					name: content.name,
					senders: content.senders,
					description: content.description,
					transport: transport
				}
			]);
		session.onAction = (req, respond) -> {
			final c = req.contents.filter(c -> c.name == content.name)[0];
			final transport = (c == null) ? null : c.transport;
			switch req.action {
				case transport_info if (s5b != null && transport != null && transport.is(JingleS5B.XMLNS)):
					respond();
					s5b.handleInfo(transport);
				case transport_replace if (transport != null):
					final ibb = JingleIBB.parseTransport(transport);
					respond();
					if (ibb == null) {
						session.send(transport_reject, [{creator: content.creator, name: content.name, transport: transport}]);
						return;
					}
					if (s5b != null)
						s5b.close();
					final blockSize = Std.int(Math.min(ibb.blockSize, maxBlockSize));
					JingleIBB.receive(session, ibb.sid, blockSize, file.size, options.onProgress, complete);
					session.send(transport_accept, [
						{creator: content.creator, name: content.name, transport: JingleIBB.createTransport(ibb.sid, blockSize)}
					]);
				case _:
					respond(new xmpp.Stanza.Error(cancel, feature_not_implemented));
			}
		}
		final transport = content.transport;
		final ibb = JingleIBB.parseTransport(transport);
		if (ibb != null) {
			final blockSize = Std.int(Math.min(ibb.blockSize, maxBlockSize));
			JingleIBB.receive(session, ibb.sid, blockSize, file.size, options.onProgress, complete);
			accept(JingleIBB.createTransport(ibb.sid, blockSize));
		} else if (transport != null && transport.is(JingleS5B.XMLNS) && transport.has("sid")) {
			s5b = new JingleS5B(session, content.name, content.creator, options.s5b, transport.get("sid"));
			s5b.onReady = stream -> {
				final buf = new BytesBuffer();
				var done = false;
				function finish(error:Null<xmpp.Stanza.Error>) {
					if (done)
						return;
					done = true;
					complete(error, (error == null) ? buf.getBytes() : null);
				}
				// without size the data is complete once the sender closes the connection
				stream.onClose = () -> finish((file.size == null) ? null : new xmpp.Stanza.Error(cancel, item_not_found, 'connection closed'));
				stream.onData = chunk -> {
					if (done)
						return;
					buf.add(chunk);
					if (options.onProgress != null)
						options.onProgress(buf.length);
					if (file.size != null && buf.length >= file.size)
						finish(null);
				}
			}
			// wait for the transport-replace (or the termination) of the sender
			s5b.onFailed = reason -> {};
			s5b.prepare(transport, () -> {
				accept(s5b.createTransport());
				s5b.start(transport);
			});
		} else {
			session.terminate(unsupported_transports);
		}
	}

	static function getFileContent(session:JingleSession):Null<JingleContent> {
		for (c in session.contents)
			if (c.description != null && c.description.is(XMLNS)) {
				// a file offer: the creator sends the file
				final offer = c.senders == (c.creator : String);
				return offer ? c : null;
			}
		return null;
	}

	/**
		Creates a file transfer `<description/>`.
	**/
	@:noUsing
	public static function createDescription(file:JingleFile):XML
		return XML.create("description").set("xmlns", XMLNS).append(createFile(file));

	/**
		Creates a `<file/>` element.
	**/
	@:noUsing
	public static function createFile(file:JingleFile):XML {
		final xml = XML.create("file");
		if (file.date != null)
			xml.append(XML.create("date", file.date));
		if (file.desc != null)
			xml.append(XML.create("desc", file.desc));
		if (file.mediaType != null)
			xml.append(XML.create("media-type", file.mediaType));
		if (file.name != null)
			xml.append(XML.create("name", file.name));
		if (file.range != null) {
			final range = XML.create("range");
			if (file.range.offset != null)
				range.set("offset", formatInt(file.range.offset));
			if (file.range.length != null)
				range.set("length", formatInt(file.range.length));
			xml.append(range);
		}
		if (file.size != null)
			xml.append(XML.create("size", formatInt(file.size)));
		if (file.hashes != null)
			for (h in file.hashes)
				xml.append(XML.create("hash", h.value).set("xmlns", XMLNS_HASHES).set("algo", h.algo));
		return xml;
	}

	/**
		Parses a file transfer `<description/>`, returns `null` if it has no `<file/>`.
	**/
	@:noUsing
	public static function parseDescription(xml:Null<XML>):Null<JingleFile> {
		if (xml == null || !xml.is(XMLNS))
			return null;
		final e = xml.elements.named("file")[0];
		return (e == null) ? null : parseFile(e);
	}

	/**
		Parses a `<file/>` element.
	**/
	@:noUsing
	public static function parseFile(xml:XML):JingleFile {
		final file:JingleFile = {};
		for (e in xml.elements) {
			final text:Null<String> = e.text;
			switch e.name {
				case "date":
					file.date = text;
				case "desc":
					file.desc = text;
				case "media-type":
					file.mediaType = text;
				case "name":
					file.name = text;
				case "size":
					final size = Std.parseFloat(text);
					if (!Math.isNaN(size))
						file.size = size;
				case "range":
					file.range = {};
					if (e.has("offset"))
						file.range.offset = Std.parseFloat(e.get("offset"));
					if (e.has("length"))
						file.range.length = Std.parseFloat(e.get("length"));
				case "hash" if (e.is(XMLNS_HASHES) && e.has("algo") && text != null):
					file.hashes ??= [];
					file.hashes.push({algo: e.get("algo"), value: StringTools.trim(text)});
				case _:
			}
		}
		return file;
	}

	/**
		Creates the `<received/>` payload of `session-info` confirming the receipt of a file.
	**/
	@:noUsing
	public static function createReceived(content:JingleContent):XML
		return XML.create("received")
			.set("xmlns", XMLNS)
			.set("creator", content.creator)
			.set("name", content.name);

	/**
		Returns the hash of `data` (supported algorithms: `sha-1`, `sha-256`).
	**/
	@:noUsing
	public static function hash(data:Bytes, algo = "sha-256"):Hash {
		final digest = digest(data, algo);
		if (digest == null)
			throw 'unsupported hash algorithm: $algo';
		return {algo: algo, value: Base64.encode(digest)};
	}

	/**
		Returns `true` if `data` matches the `hashes` (all of the supported algorithms),
		`null` if none of the algorithms is supported.
	**/
	@:noUsing
	public static function verify(data:Bytes, hashes:Array<Hash>):Null<Bool> {
		var verified:Null<Bool> = null;
		for (h in hashes) {
			final digest = digest(data, h.algo);
			if (digest == null)
				continue;
			final value = try Base64.decode(h.value) catch (e) null;
			if (value == null || value.compare(digest) != 0)
				return false;
			verified = true;
		}
		return verified;
	}

	static function digest(data:Bytes, algo:String):Null<Bytes> {
		final name = switch algo {
			case "sha-1": "sha1";
			case "sha-256": "sha256";
			case _: return null;
		}
		// native implementations, the portable ones are too slow for files on these targets
		#if python
		return Bytes.ofData(python.Syntax.code("bytearray(__import__('hashlib').new({0}, {1}).digest())", name, data.getData()));
		#elseif nodejs
		return js.node.Crypto.createHash(name).update(js.node.Buffer.hxFromBytes(data)).digest().hxToBytes();
		#else
		return (name == "sha1") ? haxe.crypto.Sha1.make(data) : haxe.crypto.Sha256.make(data);
		#end
	}

	static function formatInt(v:Float):String
		#if php
		// haxe 5 generates invalid php for haxe.Int32 (bodyless methods), pulled in via Int64.fromFloat
		return php.Syntax.code("sprintf('%.0f', {0})", v);
		#else
		return haxe.Int64.toStr(haxe.Int64.fromFloat(v));
		#end
}
