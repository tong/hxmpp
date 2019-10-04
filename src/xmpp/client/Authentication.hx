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
	//public static inline var XMLNS_BIND = 'urn:ietf:params:xml:ns:xmpp-bind';
	//public static inline var XMLNS_SESSION = 'urn:ietf:params:xml:ns:xmpp-session';

	@:access(xmpp.Stream)
	public static function authenticate( stream : Stream, node : String, resource : String, ?password : String, mechanism : Mechanism, onResult : ?String->Void, ?streamStart : (XML->Void)->Void ) {

		stream.input = function(str){
			var xml = XML.parse( str );
			switch xml.name {
			case 'challenge':
				var res = mechanism.createChallengeResponse( xml.text );
				res = Base64.encode( Bytes.ofString( res ) );
				stream.send( XML.create( 'response', res ).set( 'xmlns', XMLNS ) );
			case 'success':
				if( streamStart == null ) streamStart = stream.start;
				streamStart( function(features) {

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

					//stream.set( new xep.Bind( resource ), function(res) {
					stream.set( XML.create( 'bind' ).set( 'xmlns', 'urn:ietf:params:xml:ns:xmpp-bind' ).append( XML.create( 'resource', resource ) ), function(res:IQ) {

						switch res.type {
						case result:
							//stream.set( null, new xmpp.content.Session, function(res) {
							var xml = XML.create( 'session' ).set( 'xmlns', 'urn:ietf:params:xml:ns:xmpp-session' );
							stream.set( xml, function(res:IQ) {
								switch res.type {
								case result:
									onResult( null );
								case error:
									//TODO
									trace( res );
									//onComplete( 'ERROR' );
								default:
								}
								/*
								switch res.type {
								case IQType.result:
									onComplete( null );
								case IQType.error:
									trace( res );
									//onComplete( 'ERROR' );
									//TODO
									//callback( res.error );
								case _:
								//default:
								}
								*/

							});
						case error:
							//TODO
							onResult( "SSSSSSSSSSSSSSS");
							trace( res.error );

						default:
							trace( 'asd' );
						}
					});
				});
			case 'failure':
				trace( 'failure' );
			}
		};

	/*
		var xml = Xml.createElement( 'auth' );
		xml.set( 'xmlns', XMLNS );
		xml.set( 'mechanism', mechanism.name );
		//xml.set( 'client-uses-full-bind-result', 'false' );//TODO
		var text = mechanism.createAuthenticationText( node, stream.domain, password );
		if( text != null ) xml.addChild( Xml.createPCData( Base64.encode( Bytes.ofString( text ), true ) ) );
		stream.send( xml );
		//stream.send( "<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='PLAIN' client-uses-full-bind-result='true'>AHRvbmcAdGVzdA==</auth>" );
		*/
		var text = mechanism.createAuthenticationText( node, stream.domain, password );
		var auth = XML.create( 'auth' ).set( 'xmlns', XMLNS ).set( 'mechanism', mechanism.name );
		if( text != null ) auth.text = Base64.encode( Bytes.ofString( text ), true );
		stream.send( auth );
		/*
		var xml = XML.create( 'auth' ).set( 'xmlns', XMLNS ).set( 'mechanism', mechanism.name );
		var text = mechanism.createAuthenticationText( node, stream.domain, password );
		//if( text != null ) xml.append( Xml.createPCData( Base64.encode( Bytes.ofString( text ), true ) ) );
		if( text != null ) xml.text = Base64.encode( Bytes.ofString( text ), true );
		stream.send( xml );
		*/


	/* 	var auth = new xep.SASL.Auth();
		auth.mechanism = mechanism.name;
		if( text != null ) text = Base64.encode( Bytes.ofString( text ), true );
		var xml : XML = auth;
		//xml.set( 'xmlns', XMLNS );
		xml.text = text;
		stream.send( xml ); */

	}
	
}
