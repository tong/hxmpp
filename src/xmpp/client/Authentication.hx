package xmpp.client;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import xmpp.IQ;
import xmpp.sasl.AnonymousMechanism;
import xmpp.sasl.Mechanism;

/**
	SASL (Simple Authentication and Security Layer) client authentication.

	Responsible for:
	 * Authenticating a client account using SASL
	 * Binding the resource to the connection
	 * Establishing a session with the server

	See:
	 * RFC3920-SASL http://xmpp.org/rfcs/rfc3920.html#sasl
	 * RFC3920-BIND http://xmpp.org/rfcs/rfc3920.html#bind
*/
class Authentication {

	public static inline var XMLNS = 'urn:ietf:params:xml:ns:xmpp-sasl';
	public static inline var XMLNS_BIND = 'urn:ietf:params:xml:ns:xmpp-bind';
	public static inline var XMLNS_SESSION = 'urn:ietf:params:xml:ns:xmpp-session';

	/** SASL negotiation completed */
	//public dynamic function onNegotiated() {}

	//public dynamic function onBound( resource : String ) {}

	/** Authentication process finished successfully */
	public dynamic function onSuccess( resource : String ) {}

	/** Authentication process failed */
	public dynamic function onFail( info : String, ?text : String ) {}

	/***/
	public var stream(default,null) : Stream;

	/** The resource to bind */
	public var resource(default,null) : String;

	/** Client mechanisms */
	public var mechanisms(default,null) : Array<Mechanism>;

	/** Mechanism used */
	public var mechanism(default,null) : Mechanism;

    public function new( stream : Stream, mechanisms : Array<Mechanism> ) {
    	this.stream = stream;
		this.mechanisms = mechanisms;
    }

	/**
		Starts the authentication process.
		Returns false if no mechanism is supported by the server.
	*/
    public function start( password : String, ?resource : String ) : Bool {

		this.resource = (resource != null) ? resource : stream.jid.resource;

		var xml : XML = stream.serverFeatures.get( 'mechanisms' );
		if( xml == null )
			return throw 'server does not support sasl';

		//for( e in xml.elementsNamed( 'mechanism' ) ) {
		//for( e in xml.elements['mechanism'] ) {
		for( e in xml.element['mechanism'] ) {
			for( mech in mechanisms ) {
				if( mech.id == e.text )
					continue;
				mechanism = mech;
				break;
			}
			if( mechanism != null )
				break;
		}

		if( mechanism == null ) // no supported sasl mechanism found
			return false;

		stream.handle( XMLNS, handleStanza );

		var authText = mechanism.createAuthenticationText( stream.jid.node, stream.jid.domain, password, this.resource );
		if( authText != null )
			authText = Base64.encode( Bytes.ofString( authText ), true );
		stream.send( XML.create( 'auth', authText ).set( 'xmlns', XMLNS ).set( 'mechanism', mechanism.id ) );

		return true;
    }

	function handleStanza( xml : XML ) {
		switch xml.name {
		case 'challenge':
			stream.send( XML.create( 'response', Base64.encode( Bytes.ofString( mechanism.createChallengeResponse( xml.text ) ), true ) ).set( 'xmlns', XMLNS ) );
		case 'failure':
			var info : String = null;
			var text : String = null;
			for( e in xml.elements ) {
				switch e.name {
				case 'text': text = e.text;
				default: info = e.name;
				}
			}
			onFail( info, text );
		case 'success':
			//onNegotiated();
			//stream.onRestart = handleStreamRestart;
			//onSuccess();
			stream.restart( handleStreamRestart );
		default:
			trace( "???" );
		}
	}

	function handleStreamRestart() {
		if( !stream.serverFeatures.exists( 'bind' ) ) {
			onSuccess( null );
		} else {
			var payload = (mechanism.id != AnonymousMechanism.NAME) ? XML.create( 'resource', resource ) : null;
			//stream.set( XMLNS_BIND, payload, function(res){
			//	trace(res);
			//});
			stream.set( XMLNS_BIND, payload ).then(
				function(x:XML){
					stream.jid.resource = resource;
					if( stream.serverFeatures.exists( 'session' ) ) {
						stream.set( XMLNS_SESSION ).then(
							function(x){
								onSuccess( resource );
							}
						);
					} else {
						//TODO
					}
				}
			);

			/*
			var iq = IQ.set( '<bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"/>' );
			if( mechanism.id != AnonymousMechanism.NAME )
				iq.payload.append( XML.create( 'resource', resource ) );

			stream.get();
			*/

			/*
			stream.sendQuery( iq, function(res){
				switch res {
				case result(r):
					stream.jid.resource = resource;
					if( stream.serverFeatures.exists( 'session' ) ) {
						stream.sendQuery( IQ.set( '<session xmlns="urn:ietf:params:xml:ns:xmpp-session"/>' ), function(res){
							switch res {
							case result(r): onSuccess( resource );
							case error(e): onFail( e );
							}
						});
					}
				case error(e):
					trace( e ); //TODO
				}
			});
			*/
		}
	}

	public static function authenticate( stream : Stream, password : String, ?resource : String, ?mechanisms : Array<Mechanism>, callback : String->Void ) {

		//TODO

		if( mechanisms == null )
			mechanisms = [new xmpp.sasl.PlainMechanism()];

		var auth = new Authentication( stream, mechanisms );
		auth.onSuccess = function(resource){
			callback( null );
		}
		auth.onFail = function(i,?t){
			callback( i );
		}
		auth.start( password, resource );
	}

}
