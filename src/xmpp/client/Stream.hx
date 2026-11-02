package xmpp.client;

using StringTools;

/**
	Client-to-Server XMPP stream.

	https://xmpp.org/rfcs/rfc6120.html#examples-c2s
**/
class Stream extends xmpp.Stream {
	/** IANA registered `xmpp-client` port (5222) **/
	public static inline var PORT = 5222;

	/** XMPP client namespace **/
	public static inline var XMLNS = 'jabber:client';

	public function new(domain:String, ?xmlns:String, ?lang:String) {
		super(xmlns ?? XMLNS, domain, lang);
	}

	/**
		Opens the stream (or restarts it, e.g. after authentication): `callback` is called with the stream features
		once received, the stream is `ready` then.

		A stream error received before (e.g. `host-unknown`) is reported to `onError`.
	**/
	public function start(callback:(features:XML) -> Void):Stream {
		reset();
		input = (str:String) -> {
			if (ready) {
				handleString(str);
			} else if (str.startsWith('<stream:stream') || (framing && str.startsWith('<open'))) {
				final header = xmpp.Stream.readHeader(str);
				if (header == null) {
					sendStreamError('not-well-formed');
					return;
				}
				id = header.id;
				version = header.version;
			} else if (str.startsWith('<stream:error')) {
				final xml = try XML.fromString(str) catch (e) null;
				if (xml == null)
					sendStreamError('not-well-formed');
				else
					handleStreamError(xml);
			} else {
				final features = try xmpp.Stream.readFeatures(str) catch (e) {
					sendStreamError('not-well-formed');
					return;
				}
				if (features != null) {
					serverFeatures = features;
					ready = true;
					callback(features);
				}
			}
		};
		sendHeader(createStreamHeader(domain, version));
		return this;
	}
}
