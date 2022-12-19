package xmpp.client;

/**
	Client-to-Server XMPP stream.

	See: http://xmpp.org/rfcs/rfc6120.html#examples-c2s
 */
class Stream extends xmpp.Stream {
	/**
	 * IANA registered `xmpp-client` port (5222)
	 */
	public static inline var PORT = 5222;

	/**
	 * XMPP client namespace
	 */
	public static inline var XMLNS = 'jabber:client';

	public function new(domain:String, ?xmlns:String, ?lang:String) {
		super((xmlns == null) ? XMLNS : xmlns, domain, lang);
	}

	// public function start( callback : XML->Void, headerName = 'stream:stream' ) {
	// TODO public function start( callback : xmpp.Stanza.Error->XML->Void ) {
	// public function start( callback : (features:Array<XML>)->Void ) {
	public function start(callback:(features:XML) -> Void):Stream {
		reset();
		input = function(str) {
			if (str == '</stream:stream>') {
				reset();
				onEnd();
				return;
			}
			if (ready) {
				handleString(str);
			} else {
				if (id == null) {
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
		}
		output(xmpp.Stream.createHeader(XMLNS, domain, version, lang));
		return this;
	}

	override function handleXML(xml:XML) {
		if (xml.has('xmlns')) {
			if (xml.get('xmlns') != this.xmlns) {
				trace("invalid stream namespace");
				return;
			}
		}
		switch xml.name {
			case 'message':
				onMessage(xml);
			case 'presence':
				onPresence(xml);
			case 'iq':
				var iq:IQ = xml;
				switch iq.type {
					case result, error:
						if (queries.exists(iq.id)) {
							var h = queries.get(iq.id);
							queries.remove(iq.id);
							h(iq);
						} else {
							trace('??');
						}
					case get, set:
						if (iq.payload != null) {
							var ns = iq.payload.xmlns;
							if (extensions.exists(ns)) {
								extensions.get(ns)(iq);
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
								// TODO
								trace('?? unknown iq');
								var res = new IQ(error, iq.from, iq.to, iq.id);
								res.error = new xmpp.Stanza.Error(cancel, 'feature-not-implemented');
								send(res);
								// onIQ( iq );
							}
						}
				}
			case 'stream:error':
				trace("TODO");
			default:
				trace('?? invalid stanza', xml);
		}
	}
}
