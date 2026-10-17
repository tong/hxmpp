package xmpp;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import xmpp.IQ;
import xmpp.Jingle;

/**
	Transport of Jingle sessions over in-band bytestreams: the data is sent in base64 encoded chunks in iq stanzas.
	Slow but works with every server and without network access between the peers.

	[XEP-0261: Jingle In-Band Bytestreams Transport Method](https://xmpp.org/extensions/xep-0261.html)
	[XEP-0047: In-Band Bytestreams](https://xmpp.org/extensions/xep-0047.html)
**/
@xep(261)
class JingleIBB {
	public static inline var XMLNS = "urn:xmpp:jingle:transports:ibb:1";
	public static inline var XMLNS_IBB = "http://jabber.org/protocol/ibb";

	/** Recommended block size (bytes before base64 encoding) **/
	public static inline var DEFAULT_BLOCK_SIZE = 4096;

	/** Maximum block size **/
	public static inline var MAX_BLOCK_SIZE = 65535;

	/**
		Creates a `<transport/>` element.
	**/
	@:noUsing
	public static function createTransport(sid:String, blockSize = DEFAULT_BLOCK_SIZE):XML
		return XML.create("transport")
			.set("xmlns", XMLNS)
			.set("sid", sid)
			.set("block-size", Std.string(blockSize));

	/**
		Parses an in-band bytestream `<transport/>` element, returns `null` if it is none or invalid.
	**/
	@:noUsing
	public static function parseTransport(xml:Null<XML>):Null<{sid:String, blockSize:Int}> {
		if (xml == null || !xml.is(XMLNS) || !xml.has("sid"))
			return null;
		final blockSize = Std.parseInt(xml.get("block-size"));
		if (blockSize == null || blockSize <= 0 || blockSize > MAX_BLOCK_SIZE)
			return null;
		return {sid: xml.get("sid"), blockSize: blockSize};
	}

	/**
		Sends the data of `input` (to its end) to the peer of `session`: opens the bytestream `sid`, sends the chunks,
		read one at a time (each after the previous was acknowledged), and closes the bytestream. `callback` is called
		with `null` on success. `input` is not closed.
	**/
	public static function send(session:JingleSession, sid:String, blockSize:Int, input:haxe.io.Input, ?onProgress:(sent:Float) -> Void,
			callback:(error:Null<xmpp.Stanza.Error>) -> Void) {
		final stream = session.jingle.stream;
		final peer = session.peer;
		final buf = Bytes.alloc(blockSize);
		var sent = 0.0;
		var seq = 0;
		function next() {
			if (session.state == ended)
				return;
			final len = try readBlock(input, buf) catch (e) {
				callback(new xmpp.Stanza.Error(cancel, internal_server_error, 'cannot read the data: $e'));
				return;
			}
			if (len == 0) {
				stream.set(XML.create("close").set("xmlns", XMLNS_IBB).set("sid", sid), peer, res -> callback(res.error));
				return;
			}
			final chunk = XML.create("data", Base64.encode(buf.sub(0, len)))
				.set("xmlns", XMLNS_IBB)
				.set("sid", sid)
				.set("seq", Std.string(seq));
			stream.set(chunk, peer, res -> {
				if (!res.ok()) {
					callback(res.error);
					return;
				}
				sent += len;
				seq = (seq + 1) & 0xFFFF;
				if (onProgress != null)
					onProgress(sent);
				next();
			});
		}
		stream.set(XML.create("open")
			.set("xmlns", XMLNS_IBB)
			.set("sid", sid)
			.set("block-size", Std.string(blockSize))
			.set("stanza", "iq"), peer,
			res -> if (res.ok()) next() else callback(res.error));
	}

	/**
		Fills `buf` from `input` (fewer bytes only at its end), returns the number of bytes read: 0 at the end.
	**/
	@:noUsing
	public static function readBlock(input:haxe.io.Input, buf:Bytes):Int {
		var len = 0;
		while (len < buf.length) {
			final n = try input.readBytes(buf, len, buf.length - len) catch (_:haxe.io.Eof) 0;
			if (n <= 0)
				break;
			len += n;
		}
		return len;
	}

	/**
		Receives the bytestream `sid` from the peer of `session`, at most `maxSize` bytes if set.
		The data is written to `output` as it arrives if set (the callback gets no data), else collected.
		`callback` is called once the bytestream is closed with the received data, or with an error.
	**/
	public static function receive(session:JingleSession, sid:String, blockSize:Int, ?maxSize:Float, ?onProgress:(received:Float) -> Void,
			?output:haxe.io.Output, callback:(error:Null<xmpp.Stanza.Error>, data:Null<Bytes>) -> Void) {
		final jingle = session.jingle;
		final key = Jingle.key(session.peer, sid);
		jingle.ibbReceivers.set(key, new JingleIBBReceiver(session, blockSize, maxSize, onProgress, output, (error, data) -> {
			jingle.ibbReceivers.remove(key);
			callback(error, data);
		}));
	}

	@:allow(xmpp.Jingle)
	static function handleRequest(jingle:Jingle, iq:IQ, respond:Null<Response<XML>>->Void) {
		final xml = iq.payload;
		final receiver = (iq.from == null || !xml.has("sid")) ? null : jingle.ibbReceivers.get(Jingle.key(iq.from, xml.get("sid")));
		if (iq.type != Set) {
			respond(Response.failure(modify, bad_request));
			return;
		}
		if (receiver == null || receiver.session.state == ended) {
			respond(Response.failure(cancel, item_not_found));
			return;
		}
		respond(receiver.handle(xml));
	}
}

/** Receives the data of an in-band bytestream of a Jingle session (internal, kept by `Jingle`) **/
@:dox(hide)
@:allow(xmpp.JingleIBB)
class JingleIBBReceiver {
	final session:JingleSession;
	final blockSize:Int;
	final maxSize:Null<Float>;
	final onProgress:Null<(received:Float) -> Void>;
	final output:Null<haxe.io.Output>;
	final callback:(error:Null<xmpp.Stanza.Error>, data:Null<Bytes>) -> Void;
	final buf = new BytesBuffer();
	var received = 0.0;
	var opened = false;
	var seq = 0;

	function new(session, blockSize, maxSize, onProgress, output, callback) {
		this.session = session;
		this.blockSize = blockSize;
		this.maxSize = maxSize;
		this.onProgress = onProgress;
		this.output = output;
		this.callback = callback;
	}

	function handle(xml:XML):Response<XML> {
		switch xml.name {
			case "open":
				final size = Std.parseInt(xml.get("block-size"));
				if (opened || size == null || size <= 0)
					return Response.failure(cancel, not_acceptable);
				if (size > blockSize)
					return Response.failure(modify, resource_constraint);
				if (xml.has("stanza") && xml.get("stanza") != "iq")
					return Response.failure(cancel, feature_not_implemented);
				opened = true;
				return Response.success();
			case "data" if (opened):
				if (Std.parseInt(xml.get("seq")) != seq)
					return fail(new xmpp.Stanza.Error(cancel, unexpected_request, 'unexpected sequence number'));
				final text:Null<String> = xml.text;
				final chunk = try Base64.decode(~/\s+/g.replace(text ?? "", "")) catch (e) null;
				if (chunk == null || chunk.length > blockSize)
					return fail(new xmpp.Stanza.Error(modify, bad_request));
				if (maxSize != null && received + chunk.length > maxSize)
					return fail(new xmpp.Stanza.Error(cancel, not_acceptable, 'more data than announced'));
				if (output != null) {
					final error = try {
						output.write(chunk);
						null;
					} catch (e)
						Std.string(e);
					if (error != null)
						return fail(new xmpp.Stanza.Error(cancel, resource_constraint, 'cannot write the data: $error'));
				} else
					buf.add(chunk);
				received += chunk.length;
				seq = (seq + 1) & 0xFFFF;
				if (onProgress != null)
					onProgress(received);
				return Response.success();
			case "close" if (opened):
				opened = false;
				callback(null, (output != null) ? null : buf.getBytes());
				return Response.success();
			case _:
				return Response.failure(cancel, item_not_found);
		}
	}

	function fail(error:xmpp.Stanza.Error):Response<XML> {
		opened = false;
		callback(error, null);
		return Response.fromError(error);
	}
}
