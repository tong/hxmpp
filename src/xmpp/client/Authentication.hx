package xmpp.client;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import sasl.Mechanism;

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
	public static function authenticate( stream : Stream, node : String, resource : String, ?password : String, mechanism : Mechanism, onComplete : String->Void, ?streamStart : (XML->Void)->Void ) {

		stream.processor = function(str){

			var xml = XML.parse( str );

			switch xml.name {

			case 'challenge':
				var response = mechanism.createChallengeResponse( xml.text );
				response = Base64.encode( Bytes.ofString( response ) );
				stream.send( XML.create( 'response', response ).set( 'xmlns', XMLNS ) );

			case 'success':
				/*
				if( onNegotiated != null ) {
					if( !onNegotiated() )
						return;
				}
				*/
			//	var f = if( streamStart != null ) streamStart else stream.start;
				stream.start( function(features) {

					//stream.set( new xep.Bind( null, resource ), function(res) {
					stream.set( XML.create( 'bind' ).set( 'xmlns', 'urn:ietf:params:xml:ns:xmpp-bind' ).append( XML.create( 'resource', resource ) ), function(res:IQ) {

						switch res.type {
						case result:
							//stream.set( null, new xmpp.content.Session, function(res) {
							var xml = XML.create( 'session' ).set( 'xmlns', 'urn:ietf:params:xml:ns:xmpp-session' );
							stream.set( xml, function(res:IQ) {
								switch res.type {
								case result:
									onComplete( null );
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
							onComplete( "SSSSSSSSSSSSSSS");
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

		var xml = XML.create( 'auth' ).set( 'xmlns', XMLNS ).set( 'mechanism', mechanism.name );
		var text = mechanism.createAuthenticationText( node, stream.domain, password );
		//if( text != null ) xml.append( Xml.createPCData( Base64.encode( Bytes.ofString( text ), true ) ) );
		if( text != null ) xml.text = Base64.encode( Bytes.ofString( text ), true );
		stream.send( xml );

	}
	
}
