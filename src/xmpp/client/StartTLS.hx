package xmpp.client;

/**
	https://xmpp.org/rfcs/rfc3920.html#tls
**/
class StartTLS {
	public static inline var XMLNS = 'urn:ietf:params:xml:ns:xmpp-tls';

	@:access(xmpp.Stream)
	public static function startTLS(stream:Stream, callback:(success:Bool) -> Void) {
		stream.input = function(str) {
			var xml = XML.parse(str);
			// if( xml.get( 'xmlns' ) != XMLNS ) throw '';
			// callback( xml.name == 'proceed' );
			switch xml.name {
				case 'failure':
					callback(false);
				case 'proceed':
					callback(true);
			}
		};
		stream.send(XML.create('starttls').set('xmlns', XMLNS));
	}
}
