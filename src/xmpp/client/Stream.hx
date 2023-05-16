package xmpp.client;

/**
	Client-to-Server XMPP stream.

	See: http://xmpp.org/rfcs/rfc6120.html#examples-c2s
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
					var header = xmpp.Stream.readHeader(str);
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

	function handleXML(xml:XML) {
		if (xml.has(xmlns) && xml.get('xmlns') != xmlns) {
			trace("invalid stream namespace");
			return;
        }
		switch xml.name {
        case 'message': onMessage(xml);
        case 'presence': onPresence(xml);
        case 'iq':
            final iq:IQ = xml;
            switch iq.type {
            case Result, Error:
                if (queries.exists(iq.id)) {
                    final h = queries.get(iq.id);
                    queries.remove(iq.id);
                    h(iq);
                } else {
                    #if debug
                    trace('unhandled iq response');
                    #end
                }
            case Get, Set:
                if (iq.payload != null) {
                    final ns = iq.payload.xmlns;
                    if (extensions.exists(ns)) {
                        extensions.get(ns)(iq);
                        //
                        // var ext = extensions.get(ns);
                        // ext(iq, res -> {
                        //     trace(res);
                        // });
                        /*
                            var res = extensions.get( ns )( iq );
                            if( res == null ) {
                                trace('NOT HANDLED BY EXTENSION');
                                //r.errors.push( new xmpp.Error( cancel, 'feature-not-implemented' ) );
                            } else {
                                send( res );
                            }
                         */
                    } else {
                        //if(onIQ(iq))
                        onIQ(iq);
                        // var res = new IQ(Error, iq.from, iq.to, iq.id);
                        // res.error = new xmpp.Stanza.Error(cancel, 'feature-not-implemented');
                        // send(res);
                    }
                }
            }
        case 'stream:error':
            trace("TODO");
        default:
            #if debug
            trace('received invalid stanza', xml);
            #end
            end();
		}
	}
}
