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

	public function new( domain : String, ?xmlns : String, ?lang : String ) {
		super( (xmlns == null) ? XMLNS : xmlns, domain, lang );
	}

	//public function start( callback : XML->Void, headerName = 'stream:stream' ) {
	//TODO public function start( callback : xmpp.Stanza.Error->XML->Void ) {
	public function start( callback : XML->Void ) {

		reset();

		processor = function(str) {

			if( str == '</stream:stream>' ) {
				ready = false;
				//state = ended;
				return;
			}

			if( ready ) {
				handleString( str );
			} else {

				if( id == null ) {

					//TODO

					/*
					var xml = XML.parse( str );
					var firstElement = xml.firstElement();
					if( firstElement != null ) {
						switch firstElement.nodeName {
						case 'stream:error':
							//TODO
							trace(">>>>>>>>>>>>>>>>");
							var error = xmpp.Stanza.Error.fromXML( firstElement );
							trace(error);
							//var error : xmpp.Stream.Error = {};

							/*
							var error = { condition : null, text : null };
							for( e in firstElement.elements() ) {
								//trace(e.nodeName,e.get('xmlns'));
								switch e.nodeName {
								case 'text':
									error.text = e.firstChild().nodeValue;
								default:
									error.condition = e.nodeName;
								}
							}
							trace(error);
							* /

						case 'stream:features':
							var features = firstElement;
							if( features != null ) {
								ready = true;
								callback( features );
							}

							/*
							var features = xmpp.Stream.readFeatures( str );
							if( features != null ) {
								ready = true;
								callback( features );
							}
							* /
						}
					}
					*/

					var header = xmpp.Stream.readHeader( str );
					id = header.id;
					version = header.version;

					var features = xmpp.Stream.readFeatures( str );
					if( features != null ) {
						ready = true;
						callback( features );
					}

				} else {
					//TODO remove
					var features = xmpp.Stream.readFeatures( str );
					ready = true;
					callback( features );
					//TODO
				}
			}
		}

		output( xmpp.Stream.createHeader( XMLNS, domain, version, lang ) );

		return this;
	}

	override function handleXML( xml : XML ) {
		if( xml.has( 'xmlns' ) ) {
			if( xml.get( 'xmlns' ) != this.xmlns ) {
				trace( "invalid stream namespace" );
				return;
			}
		}
		switch xml.name {
		case 'message':
			onMessage( xml );
		case 'presence':
			onPresence( xml );
		case 'iq':
			var iq = IQ.fromXML( xml );
			switch iq.type {
			case result, error:
				if( queries.exists( iq.id ) ) {
					var h = queries.get( iq.id );
					queries.remove( iq.id );
					h( iq );
				} else {
					trace( '??' );
				}
			case get,set:
				if( iq.content != null ) {
					var ns = iq.content.get( 'xmlns' );
					if( extensions.exists( ns ) ) {
						trace("EEEEEEEEEEEEEEEEEEEEEEEE");
						var res = extensions.get( ns )( iq );
						if( res == null ) {
							trace('NOT HANDLED BY EXTENSION');
							//r.errors.push( new xmpp.Error( cancel, 'feature-not-implemented' ) );
						} else {
							trace(res);
							trace("RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
							send( res );
						}
					} else {
						trace( '?? unknown iq' );
						onIQ( iq );
					}
				}
			}
		case 'stream:error':
			trace("TODO");
		default:
			trace( '?? invalid stanza' );
		}
	}

}
