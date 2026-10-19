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
	var ?onProgress:(bytes:Float) -> Void;

	/**
		Receiver: the data is written to it as it arrives (it is not closed), instead of being kept in memory: files of
		any size. The callback of `receiveFile` gets no data then.
	**/
	var ?output:haxe.io.Output;
}

/** The data of a file to send: its size, and how to read it (from the start, also more than once) **/
typedef JingleFileSource = {
	var size:Float;

	/** Opens the data for reading from the start (closed once read): e.g. `() -> sys.io.File.read(path)` **/
	var open:() -> haxe.io.Input;
}

/**
	The data of a file to send: `Bytes`, or a `JingleFileSource` read as it is sent (files of any size).
**/
@:forward
abstract JingleFileData(JingleFileSource) from JingleFileSource to JingleFileSource {
	@:from static function fromBytes(bytes:Bytes):JingleFileData
		return {size: bytes.length, open: () -> new haxe.io.BytesInput(bytes)};
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

	static inline var REQUEST_NAME = "a-file-request";

	/** Blocks read and sent over SOCKS5 bytestreams **/
	static inline var BLOCK_SIZE = 65536;

	/** Bytes sent over SOCKS5 bytestreams before waiting for them to be written: the data kept in memory **/
	static inline var WINDOW = 1024 * 1024;

	/**
		Offer `data` as `file` to `peer` (a full jid) and send it once accepted.

		The data is sent with SOCKS5 bytestreams if `options.s5b` is set (falling back to in-band bytestreams if no
		connection can be established), otherwise with in-band bytestreams. It is read as it is sent: a
		`JingleFileSource` (e.g. of a file) is never held in memory as a whole.
		The `size` and a `sha-256` hash are added to `file` if not set (the hash reads all data first: for large files
		better computed before, e.g. in a thread, with `hashInput`).
		`callback` is called once the session ended, with the reason: `success` if the receiver confirmed the transfer.
	**/
	@:noUsing
	public static function sendFile(jingle:Jingle, peer:String, file:JingleFile, data:JingleFileData, ?options:JingleFileTransferOptions,
			callback:(reason:JingleReasonInfo) -> Void):JingleSession {
		final file = Reflect.copy(file);
		file.size ??= data.size;
		if (file.hashes == null || file.hashes.length == 0)
			file.hashes = hashInput(data.open(), ["sha-256"]);
		final session = jingle.createSession(peer);
		final content:JingleContent = {
			creator: initiator,
			name: CONTENT_NAME,
			senders: initiator,
			description: createDescription(file)
		};
		new FileSession(session, content, true, options ?? {}, data, null, (reason, _) -> callback(reason)).start();
		return session;
	}

	/**
		Returns the offered file of a session initiated by the peer, or `null` if the session is no file offer.
	**/
	@:noUsing
	public static function getFileOffer(session:JingleSession):Null<JingleFile> {
		final content = getFileContent(session, true);
		return (content == null) ? null : parseDescription(content.description);
	}

	/**
		Accept the file offer of `session` and receive the data.

		Offers with in-band bytestreams and SOCKS5 bytestreams are accepted; without `options.s5b`
		no SOCKS5 connection is attempted (the sender falls back to in-band bytestreams).
		`callback` is called once the session ended: with the reason `success` and the data if the transfer succeeded.
		With `options.output` the data is written to it as it arrives (any size) and the callback gets no data.
		The data is verified with the offered size and hashes (if supported, e.g. `sha-1` and `sha-256`).
	**/
	@:noUsing
	public static function receiveFile(session:JingleSession, ?options:JingleFileTransferOptions,
			callback:(reason:JingleReasonInfo, data:Null<Bytes>) -> Void) {
		final content = getFileContent(session, true);
		final file = (content == null) ? null : parseDescription(content.description);
		if (file == null) {
			session.onTerminate = reason -> callback(reason, null);
			session.terminate(unsupported_applications);
			return;
		}
		new FileSession(session, content, false, options ?? {}, null, file, callback).answer(content.description);
	}

	/**
		Request the file `file` from `peer` (a full jid): the peer sends it ([XEP-0329](https://xmpp.org/extensions/xep-0329.html):
		`name` is its path in the shared directories, see `FileSharing`); `size` and `hashes` (if known, e.g. from the
		listing) verify the data, otherwise those of the peer's answer.
		The transports and options are those of `receiveFile`; `callback` is called once the session ended, with the
		reason (`success`: received and verified) and the data (none with `options.output`).
	**/
	@:noUsing
	public static function requestFile(jingle:Jingle, peer:String, file:JingleFile, ?options:JingleFileTransferOptions,
			callback:(reason:JingleReasonInfo, data:Null<Bytes>) -> Void):JingleSession {
		final session = jingle.createSession(peer);
		final content:JingleContent = {
			creator: initiator,
			name: REQUEST_NAME,
			senders: responder,
			description: createDescription(file)
		};
		new FileSession(session, content, true, options ?? {}, null, Reflect.copy(file), callback).start();
		return session;
	}

	/**
		Returns the file requested in a session initiated by the peer (its `name`: the path), or `null` if the session
		is no file request.
	**/
	@:noUsing
	public static function getFileRequest(session:JingleSession):Null<JingleFile> {
		final content = getFileContent(session, false);
		return (content == null) ? null : parseDescription(content.description);
	}

	/**
		Answer the file request of `session`: accept it with `file` (the details, e.g. size and hashes, the receiver
		verifies the data with) and send `data`. Decline with `session.terminate(decline)` (or another reason).
		`callback` is called once the session ended, with the reason: `success` if the receiver confirmed the transfer.
	**/
	@:noUsing
	public static function answerFileRequest(session:JingleSession, file:JingleFile, data:JingleFileData, ?options:JingleFileTransferOptions,
			callback:(reason:JingleReasonInfo) -> Void) {
		final content = getFileContent(session, false);
		if (content == null) {
			session.onTerminate = callback;
			session.terminate(unsupported_applications);
			return;
		}
		final file = Reflect.copy(file);
		file.size ??= data.size;
		new FileSession(session, content, false, options ?? {}, data, null, (reason, _) -> callback(reason)).answer(createDescription(file));
	}

	/** The file content of a session initiated by the peer: an offer (the initiator sends), or a request (the responder sends) **/
	static function getFileContent(session:JingleSession, offer:Bool):Null<JingleContent> {
		for (c in session.contents)
			if (c.description != null && c.description.is(XMLNS)) {
				final sentByCreator = c.senders == (c.creator : String);
				return (sentByCreator == offer) ? c : null;
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
		final digest = Digest.make(data, algo);
		if (digest == null)
			throw 'unsupported hash algorithm: $algo';
		return {algo: algo, value: Base64.encode(digest)};
	}

	/**
		Returns the hashes of the data of `input` with `algos` (read to its end, then closed), e.g. of a large file in a
		thread before offering it. Throws on read errors and unsupported algorithms.
	**/
	@:noUsing
	public static function hashInput(input:haxe.io.Input, ?algos:Array<String>):Array<Hash> {
		final digests = [
			for (algo in algos ?? ["sha-256"])
				Digest.create(algo) ?? throw 'unsupported hash algorithm: $algo'
		];
		final buf = Bytes.alloc(BLOCK_SIZE);
		try {
			var len = 0;
			while ((len = JingleIBB.readBlock(input, buf)) > 0)
				for (d in digests)
					d.update(buf, 0, len);
		} catch (e) {
			input.close();
			throw e;
		}
		input.close();
		return [for (d in digests) {algo: d.algo, value: Base64.encode(d.finish())}];
	}

	/**
		Returns `true` if `data` matches the `hashes` (all of the supported algorithms),
		`null` if none of the algorithms is supported.
	**/
	@:noUsing
	public static function verify(data:Bytes, hashes:Array<Hash>):Null<Bool> {
		var verified:Null<Bool> = null;
		for (h in hashes) {
			final digest = Digest.make(data, h.algo);
			if (digest == null)
				continue;
			final value = try Base64.decode(h.value) catch (e) null;
			if (value == null || value.compare(digest) != 0)
				return false;
			verified = true;
		}
		return verified;
	}

	static function formatInt(v:Float):String
		#if php
		// haxe 5 generates invalid php for haxe.Int32 (bodyless methods), pulled in via Int64.fromFloat
		return php.Syntax.code("sprintf('%.0f', {0})", v);
		#else
		return haxe.Int64.toStr(haxe.Int64.fromFloat(v));
		#end
}

/**
	The data received of a file: counted and hashed (the offered algorithms supported) as it arrives, written to an
	output, or kept.
**/
private class ReceivedData extends haxe.io.Output {
	public var length(default, null) = 0.0;

	final output:Null<haxe.io.Output>;
	final buffer:Null<BytesBuffer>;
	var hashes:Array<Hash> = [];
	var digests:Array<Digest> = [];

	public function new(output:Null<haxe.io.Output>, hashes:Null<Array<Hash>>) {
		this.output = output;
		buffer = (output == null) ? new BytesBuffer() : null;
		expect(hashes);
	}

	/** The hashes to verify (those supported), before data arrives **/
	public function expect(hashes:Null<Array<Hash>>) {
		this.hashes = [for (h in hashes ?? []) if (Digest.ALGORITHMS.contains(h.algo)) h];
		digests = [for (h in this.hashes) Digest.create(h.algo)];
	}

	override public function writeByte(c:Int) {
		final b = Bytes.alloc(1);
		b.set(0, c);
		writeBytes(b, 0, 1);
	}

	override public function writeBytes(b:Bytes, pos:Int, len:Int):Int {
		if (output != null)
			output.writeFullBytes(b, pos, len);
		else
			buffer.addBytes(b, pos, len);
		for (d in digests)
			d.update(b, pos, len);
		length += len;
		return len;
	}

	/** The data matches the hashes (all supported), `null` if none of them is supported **/
	public function verify():Null<Bool> {
		if (digests.length == 0)
			return null;
		for (i in 0...digests.length) {
			final value = try Base64.decode(hashes[i].value) catch (e) null;
			if (value == null || value.compare(digests[i].finish()) != 0)
				return false;
		}
		return true;
	}

	/** The data, `null` if it was written to the output **/
	public function bytes():Null<Bytes>
		return buffer?.getBytes();
}

/**
	The transfer of the file of a session: the transport by the role in the session (the initiator offers the
	transport and falls back to in-band bytestreams if no SOCKS5 connection can be established), the data by its
	direction (the sender reads it as it sends, the receiver verifies it and ends the session).
	Offers: the initiator sends; requests (XEP-0329): the responder sends.
**/
@:access(xmpp.JingleFileTransfer)
private class FileSession {
	final session:JingleSession;
	final content:JingleContent;
	final initiator:Bool;
	final sending:Bool;
	final options:JingleFileTransferOptions;

	/** In-band bytestreams: the block size offered (initiator), at most accepted (responder) **/
	final blockSize:Int;

	/** Sending: the data **/
	final data:Null<JingleFileData>;

	/** Receiving: the file expected (size, hashes), the data received **/
	final file:Null<JingleFile>;

	var received:Null<ReceivedData>;

	final callback:(reason:JingleReasonInfo, data:Null<Bytes>) -> Void;

	var s5b:Null<JingleS5B>;
	var ibbSid:Null<String>;

	/** The data being read (sending), closed when sent or the session ends **/
	var input:Null<haxe.io.Input>;

	/** The receiver got all data (verified or not) **/
	var completed = false;

	public function new(session:JingleSession, content:JingleContent, initiator:Bool, options:JingleFileTransferOptions,
			data:Null<JingleFileData>, file:Null<JingleFile>, callback:(reason:JingleReasonInfo, data:Null<Bytes>) -> Void) {
		this.session = session;
		this.content = content;
		this.initiator = initiator;
		this.options = options;
		this.data = data;
		this.file = file;
		this.callback = callback;
		sending = data != null;
		blockSize = options.blockSize ?? (sending ? JingleIBB.DEFAULT_BLOCK_SIZE : JingleIBB.MAX_BLOCK_SIZE);
		if (!sending)
			received = new ReceivedData(options.output, file?.hashes);
		var result:Null<Bytes> = null;
		session.onTerminate = reason -> {
			if (s5b != null)
				s5b.close();
			closeInput();
			if (received != null && reason.condition == success)
				result = received.bytes();
			callback(reason, result);
		}
		// the receiver confirms the receipt of the file before terminating the session
		if (sending)
			session.onInfo = payload -> payload.filter(e -> e.name == "received" && e.is(JingleFileTransfer.XMLNS)).length == payload.length;
		session.onAction = action;
	}

	/** The initiator: offers the transport, initiates the session **/
	public function start() {
		session.onAccept = accepted;
		if (options.s5b != null) {
			s5b = new JingleS5B(session, content.name, content.creator, options.s5b);
			s5b.prepare(null, () -> {
				content.transport = s5b.createTransport();
				session.initiate([content]);
			});
		} else {
			ibbSid = xmpp.Stream.makeRandomId();
			content.transport = JingleIBB.createTransport(ibbSid, blockSize);
			if (!sending)
				receiveIBB(ibbSid, blockSize);
			session.initiate([content]);
		}
	}

	/** The responder: accepts the session (with `description`) and the transport of the initiator **/
	public function answer(description:XML) {
		function accept(transport:XML)
			session.accept([
				{
					creator: content.creator,
					name: content.name,
					senders: content.senders,
					description: description,
					transport: transport
				}
			]);
		final transport = content.transport;
		final ibb = JingleIBB.parseTransport(transport);
		if (ibb != null) {
			final size = Std.int(Math.min(ibb.blockSize, blockSize));
			if (!sending)
				receiveIBB(ibb.sid, size);
			accept(JingleIBB.createTransport(ibb.sid, size));
			if (sending)
				sendIBB(ibb.sid, size);
		} else if (transport != null && transport.is(JingleS5B.XMLNS) && transport.has("sid")) {
			s5b = new JingleS5B(session, content.name, content.creator, options.s5b, transport.get("sid"));
			s5b.onReady = ready;
			// wait for the transport-replace (or the termination) of the initiator
			s5b.onFailed = reason -> {};
			s5b.prepare(transport, () -> {
				accept(s5b.createTransport());
				s5b.start(transport);
			});
		} else
			session.terminate(unsupported_transports);
	}

	/** The initiator: the responder accepted, with its transport (and for requests the details of the file) **/
	function accepted(contents:Array<JingleContent>) {
		final c = contents.filter(c -> c.name == content.name)[0];
		final transport = (c == null) ? null : c.transport;
		// a request: the size and hashes of the sender, unless requested
		if (!sending && c?.description != null) {
			final details = JingleFileTransfer.parseDescription(c.description);
			if (details != null) {
				file.size ??= details.size;
				if (file.hashes == null || file.hashes.length == 0)
					received.expect(details.hashes);
			}
		}
		if (s5b != null) {
			if (transport == null || !transport.is(JingleS5B.XMLNS)) {
				session.terminate(unsupported_transports);
				return;
			}
			s5b.onFailed = fallback;
			s5b.onReady = ready;
			s5b.start(transport);
		} else {
			final ibb = JingleIBB.parseTransport(transport);
			if (ibb == null || ibb.sid != ibbSid) {
				session.terminate(unsupported_transports);
				return;
			}
			if (sending)
				sendIBB(ibb.sid, Std.int(Math.min(blockSize, ibb.blockSize)));
		}
	}

	/** The initiator: no SOCKS5 connection, in-band bytestreams instead (unless `fallback` is `false`) **/
	function fallback(reason:String) {
		if (session.state == ended)
			return;
		if (options.fallback == false) {
			session.terminate(connectivity_error, reason);
			return;
		}
		ibbSid = xmpp.Stream.makeRandomId();
		if (!sending)
			receiveIBB(ibbSid, blockSize);
		session.send(transport_replace, [
			{creator: content.creator, name: content.name, transport: JingleIBB.createTransport(ibbSid, blockSize)}
		]);
	}

	function action(req:JingleRequest, respond:(?error:xmpp.Stanza.Error) -> Void) {
		final c = req.contents.filter(c -> c.name == content.name)[0];
		final transport = (c == null) ? null : c.transport;
		switch req.action {
			case transport_info if (s5b != null && transport != null && transport.is(JingleS5B.XMLNS)):
				respond();
				s5b.handleInfo(transport);
			case transport_accept if (initiator && ibbSid != null):
				final ibb = JingleIBB.parseTransport(transport);
				if (ibb == null || ibb.sid != ibbSid) {
					respond(new xmpp.Stanza.Error(modify, bad_request));
					session.terminate(failed_transport);
					return;
				}
				respond();
				if (s5b != null)
					s5b.close();
				if (sending)
					sendIBB(ibb.sid, Std.int(Math.min(blockSize, ibb.blockSize)));
			case transport_reject if (initiator && ibbSid != null):
				respond();
				session.terminate(failed_transport);
			case transport_replace if (!initiator && transport != null):
				final ibb = JingleIBB.parseTransport(transport);
				respond();
				if (ibb == null) {
					session.send(transport_reject, [{creator: content.creator, name: content.name, transport: transport}]);
					return;
				}
				if (s5b != null)
					s5b.close();
				final size = Std.int(Math.min(ibb.blockSize, blockSize));
				if (!sending)
					receiveIBB(ibb.sid, size);
				session.send(transport_accept, [
					{creator: content.creator, name: content.name, transport: JingleIBB.createTransport(ibb.sid, size)}
				]);
				if (sending)
					sendIBB(ibb.sid, size);
			case _:
				respond(new xmpp.Stanza.Error(cancel, feature_not_implemented));
		}
	}

	/** The SOCKS5 bytestream is established: the data is sent or received **/
	function ready(stream:JingleS5BStream) {
		if (sending)
			sendStream(stream);
		else
			receiveStream(stream);
	}

	function closeInput() {
		if (input != null)
			try
				input.close()
			catch (_) {}
		input = null;
	}

	function openInput():Bool {
		closeInput();
		input = try data.open() catch (e) {
			session.terminate(failed_application, 'cannot read the data: $e');
			null;
		}
		return input != null;
	}

	/** Sends the data over the SOCKS5 bytestream: a window of blocks at a time, the next once they are written **/
	function sendStream(stream:JingleS5BStream) {
		if (!openInput())
			return;
		final buf = Bytes.alloc(JingleFileTransfer.BLOCK_SIZE);
		var sent = 0.0;
		function pump() {
			if (session.state == ended || input == null)
				return;
			var queued = 0;
			while (queued < JingleFileTransfer.WINDOW) {
				// a write can end the session (a receiver with all data terminates it): the input is closed then
				if (session.state == ended || input == null)
					return;
				final len = try JingleIBB.readBlock(input, buf) catch (e) {
					session.terminate(failed_application, 'cannot read the data: $e');
					return;
				}
				if (len == 0) {
					// all sent: the receiver terminates the session after verifying the data
					closeInput();
					final total = sent;
					stream.written(() -> if (options.onProgress != null) options.onProgress(total));
					return;
				}
				stream.write(buf.sub(0, len));
				queued += len;
				sent += len;
			}
			final written = sent;
			stream.written(() -> {
				if (options.onProgress != null)
					options.onProgress(written);
				pump();
			});
		}
		pump();
	}

	/** Receives the data of the SOCKS5 bytestream: complete with the size, or (without) once the sender closes it **/
	function receiveStream(stream:JingleS5BStream) {
		var done = false;
		function finish(error:Null<xmpp.Stanza.Error>) {
			if (done)
				return;
			done = true;
			complete(error, null);
		}
		stream.onClose = () -> finish((file.size == null) ? null : new xmpp.Stanza.Error(cancel, item_not_found, 'connection closed'));
		stream.onData = chunk -> {
			if (done)
				return;
			final error = try {
				received.write(chunk);
				null;
			} catch (e) Std.string(e);
			if (error != null) {
				done = true;
				session.terminate(failed_application, 'cannot write the data: $error');
				return;
			}
			if (options.onProgress != null)
				options.onProgress(received.length);
			if (file.size != null && received.length >= file.size)
				finish(null);
		}
	}

	function sendIBB(sid:String, size:Int) {
		if (!openInput())
			return;
		JingleIBB.send(session, sid, size, input, options.onProgress, error -> {
			closeInput();
			if (error != null)
				session.terminate(failed_transport, error.condition);
			// otherwise the receiver terminates the session after verifying the data
		});
	}

	function receiveIBB(sid:String, size:Int)
		JingleIBB.receive(session, sid, size, file.size, options.onProgress, received, complete);

	/** The receiver got the data: verifies size and hashes, confirms it and ends the session **/
	function complete(error:Null<xmpp.Stanza.Error>, _:Null<Bytes>) {
		if (session.state == ended || completed)
			return;
		completed = true;
		if (error != null) {
			session.terminate(failed_transport, error.condition);
			return;
		}
		if (file.size != null && received.length != file.size) {
			session.terminate(media_error, 'size mismatch');
			return;
		}
		if (received.verify() == false) {
			session.terminate(media_error, 'hash mismatch');
			return;
		}
		session.info([JingleFileTransfer.createReceived(content)]);
		session.terminate(success);
	}
}
