package xmpp.client;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import xmpp.sasl.Mechanism;

/**
	SASL (Simple Authentication and Security Layer) client authentication.

	- [RFC3920-SASL](http://xmpp.org/rfcs/rfc3920.html#sasl)
	- [RFC3920-BIND](http://xmpp.org/rfcs/rfc3920.html#bind)

	This class is responsible for:

	 1. Authenticating a client account using SASL
	 2. Binding the resource to the connection
	 3. Establishing a session with the server
*/
class Authentication {

	public static inline var XMLNS = 'urn:ietf:params:xml:ns:xmpp-sasl';
	public static inline var XMLNS_BIND = 'urn:ietf:params:xml:ns:xmpp-bind';
	public static inline var XMLNS_SESSION = 'urn:ietf:params:xml:ns:xmpp-session';

	@:access(xmpp.Stream)
	public static function authenticate( stream : Stream, node : String, resource : String, ?password : String, mechanism : Mechanism, onResult : (?error:xmpp.Stanza.Error)->Void, ?streamStart : (XML->Void)->Void ) {
		stream.input = function(str) {
			var xml = XML.parse( str );
			switch xml.name {
			case 'challenge':
				var res = mechanism.createChallengeResponse( xml.text );
				res = Base64.encode( Bytes.ofString( res ) );
				stream.send( XML.create( 'response', res ).set( 'xmlns', XMLNS ) );
			case 'success':
				if( streamStart == null ) streamStart = stream.start;
				streamStart( features -> {
					//TODO
					/* trace(features);
					var bindSupport : Bool = null;
					var sessionSupport : Bool = null;
					for( e in features ) {
						var ns = e.get( 'xmlns' );
						switch ns {
						case 'urn:ietf:params:xml:ns:xmpp-bind': bindSupport = true;
						case 'urn:ietf:params:xml:ns:xmpp-session': sessionSupport = true;
						}
					}
					if( !bindSupport )
						onResult();
 					*/
					stream.set( XML.create( 'bind' ).set( 'xmlns', XMLNS_BIND ).append( XML.create( 'resource', resource ) ), function(res) {
						switch res.type {
						case result:
							var xml = XML.create( 'session' ).set( 'xmlns', XMLNS_SESSION );
							stream.set( xml, function(res:IQ) {
								switch res.type {
								case result: onResult( null );
								case error: onResult( res.error );
								case _: throw 'invalid session response';
								}
							});
						case error: onResult( res.error );
						case _: throw 'invalid bind response';
						}
					});
				});
			case 'failure': throw 'SASL failure';
			}
		};
		var text = mechanism.createAuthenticationText( node, stream.domain, password );
		var auth = XML.create( 'auth' ).set( 'xmlns', XMLNS ).set( 'mechanism', mechanism.name );
		if( text != null ) auth.text = Base64.encode( Bytes.ofString( text ), true );
		stream.send( auth );
	}
	
}
