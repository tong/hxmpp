package xmpp;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import xmpp.Stanza;

/**
	A bidirectional bytestream transferring base64 encoded chunks of data in IQ stanzas over the XMPP stream.

	Open a bytestream with `open`, or `accept` an incoming `<open/>` request, then `send` chunks of data
	and pass the incoming IQs of the bytestream to `handle`.

	[XEP-0047: In-Band Bytestreams](https://xmpp.org/extensions/xep-0047.html)
**/
@xep(47)
class IBBytestream {
	public static inline var XMLNS = "http://jabber.org/protocol/ibb";

	/** Recommended block size **/
	public static inline var DEFAULT_BLOCK_SIZE = 4096;

	/** Maximum block size **/
	public static inline var MAX_BLOCK_SIZE = 65535;

	public final stream:Stream;

	/** The peer, `null` if the bytestream is not open **/
	public var entity(default, null):Null<String>;

	/** The session id, `null` if the bytestream is not open **/
	public var sid(default, null):Null<String>;

	/** Maximum size of a chunk in bytes (before base64 encoding) **/
	public var blockSize(default, null) = 0;

	/** Sequence number of the next sent chunk **/
	public var seq(default, null) = 0;

	/** Sequence number of the next expected received chunk **/
	var receiveSeq = 0;

	public function new(stream:Stream) {
		this.stream = stream;
	}

	/**
		Opens a bytestream to `entity`.
	**/
	public function open(entity:String, ?sid:String, blockSize = DEFAULT_BLOCK_SIZE, handler:Response<XML>->Void):IBBytestream {
		this.entity = entity;
		this.sid = sid ?? Stream.makeRandomId(8);
		this.blockSize = blockSize;
		seq = receiveSeq = 0;
		stream.set(XML.create("open")
			.set("xmlns", XMLNS)
			.set("sid", this.sid)
			.set("block-size", Std.string(blockSize))
			.set("stanza", "iq"), entity, res -> {
				if (!res.ok())
					reset();
				handler(res);
			});
		return this;
	}

	/**
		Sends a chunk of at most `blockSize` bytes.
		On an error response the bytestream should be closed.
	**/
	public function send(bytes:Bytes, handler:Response<XML>->Void) {
		if (bytes.length > blockSize)
			throw 'chunk exceeds block size ($blockSize)';
		final data = XML.create("data", Base64.encode(bytes))
			.set("xmlns", XMLNS)
			.set("sid", sid)
			.set("seq", Std.string(seq));
		seq = (seq + 1) & 0xFFFF;
		stream.set(data, entity, handler);
	}

	/**
		Accepts an incoming `<open/>` request, unless `confirm` returns an error for the proposed block size.
		Returns `null` if the IQ is not an `<open/>` request or this bytestream is already open.
	**/
	public function accept(iq:IQ, ?confirm:Int->Null<Stanza.Error>):Null<IBBytestream> {
		final xml = iq.payload;
		if (iq.type != Set || xml == null || !xml.is(XMLNS) || xml.name != "open" || entity != null)
			return null;
		final blockSize = Std.parseInt(xml.get("block-size"));
		final error:Null<Stanza.Error> = if (!xml.has("sid") || blockSize == null || blockSize <= 0 || blockSize > MAX_BLOCK_SIZE) {
			new Stanza.Error(modify, bad_request);
		} else if (xml.has("stanza") && xml.get("stanza") != "iq") {
			new Stanza.Error(cancel, feature_not_implemented);
		} else if (confirm != null) {
			confirm(blockSize);
		} else null;
		if (error != null) {
			stream.send(iq.createError(error));
			return this;
		}
		entity = iq.from;
		sid = xml.get("sid");
		this.blockSize = blockSize;
		seq = receiveSeq = 0;
		stream.send(iq.createResult());
		return this;
	}

	/**
		Handles an incoming `<data/>` or `<close/>` request of this bytestream.
		Returns `null` if the IQ does not belong to this bytestream.
	**/
	public function handle(iq:IQ, onData:Bytes->Void, onClose:Void->Void):Null<IBBytestream> {
		final xml = iq.payload;
		if (sid == null || iq.type != Set || xml == null || !xml.is(XMLNS) || xml.get("sid") != sid)
			return null;
		switch xml.name {
			case "data":
				if (Std.parseInt(xml.get("seq")) != receiveSeq) {
					stream.send(iq.createError(new Stanza.Error(cancel, unexpected_request)));
					close();
					onClose();
					return this;
				}
				final text:Null<String> = xml.text;
				final bytes = try Base64.decode(~/\s+/g.replace(text ?? "", "")) catch (e) null;
				if (bytes == null || bytes.length > blockSize) {
					stream.send(iq.createError(new Stanza.Error(cancel, bad_request)));
					return this;
				}
				receiveSeq = (receiveSeq + 1) & 0xFFFF;
				stream.send(iq.createResult());
				onData(bytes);
			case "close":
				reset();
				stream.send(iq.createResult());
				onClose();
			case _:
				return null;
		}
		return this;
	}

	/**
		Closes the bytestream.
	**/
	public function close(?handler:Response<XML>->Void) {
		if (sid == null)
			return;
		final xml = XML.create("close").set("xmlns", XMLNS).set("sid", sid);
		final to = entity;
		reset();
		stream.set(xml, to, handler);
	}

	function reset() {
		entity = sid = null;
		blockSize = seq = receiveSeq = 0;
	}
}
