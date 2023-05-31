package xmpp.client;

/**
	Client-to-Server XMPP stream.

	https://xmpp.org/rfcs/rfc6120.html#examples-c2s
**/
class Stream extends xmpp.Stream {

	/** IANA registered `xmpp-client` port (5222) **/
	public static inline var PORT = 5222;

	/** XMPP client namespac **/
	public static inline var XMLNS = 'jabber:client';

	public function new(domain:String, ?xmlns:String, ?lang:String) {
		super(xmlns ?? XMLNS, domain, lang);
	}

	public function start(callback:(features:XML) -> Void):Stream {
		reset();
		input = (str:String) -> {
            if(ready) {
				handleString(str);
			} else {
				if(id == null) {
				    final header = xmpp.Stream.readHeader(str);
					id = header.id;
					version = header.version;
					var features = xmpp.Stream.readFeatures(str);
					if (features != null) {
						ready = true;
						callback(features);
					}
				} else {
					// TODO remove
					var features = xmpp.Stream.readFeatures(str);
					if (features != null) {
						ready = true;
						callback(features);
					}
				}
            }
        };
		output(xmpp.Stream.createHeader(XMLNS, domain, version, lang));
		return this;
	}
}
