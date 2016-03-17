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

	public static inline var XMLNS = "urn:ietf:params:xml:ns:xmpp-sasl";

	/** SASL negotiation completed */
	//public dynamic function onNegotiated() {}

    /** Authentication process finished successfully */
	//public dynamic function onSuccess() {}
	//public dynamic function onBound( resource : String ) {}
	public dynamic function onSuccess( resource : String ) {}

	/** Authentication process failed */
	public dynamic function onFail( info : String, ?text : String ) {}

	/***/
	public var stream(default,null) : Stream;

	/** The resource to bind */
	public var resource(default,null) : String;

	/** Available client mechanisms */
	public var mechanisms(default,null) : Array<Mechanism>;

	/** Mechanism used */
	public var mechanism(default,null) : Mechanism;

	//var serverMechanisms : Array<String>;
	var callback : String->Void;

    public function new( stream : Stream, mechanisms : Array<Mechanism> ) {
    	this.stream = stream;
		this.mechanisms = mechanisms;
    }

	/**
		Starts the authentication process.
	*/
    public function start( password : String, ?resource : String, callback : String->Void ) {

		this.resource = resource;
		this.callback = callback;

		var xml : XML = stream.serverFeatures.get( "mechanisms" );
		if( xml == null )
			throw "server doesn't support sasl";
		//var serverMechanisms = SASL.parseMechanisms( x );
		var serverMechanisms = new Array<String>();
        for( e in xml.elements() )
            if( e.name == "mechanism" )
                serverMechanisms.push( e.value );

		for( serverMechanism in serverMechanisms ) {
			for( mechanism in mechanisms ) {
				if( mechanism.id != serverMechanism )
					continue;
				this.mechanism = mechanism;
				break;
			}
			if( this.mechanism != null )
				break;
		}

		if( mechanism == null ) {
			trace( 'no supported sasl mechanism found' );
			return;
		}

		stream.handle( XMLNS, handleXml );

		var authText = mechanism.createAuthenticationText( stream.jid.node, stream.jid.domain, password, stream.jid.resource );
		if( authText != null ) authText = Base64.encode( Bytes.ofString( authText ), true );
		stream.sendString( XML.create( 'auth', authText ).set( 'xmlns', XMLNS ).set( 'mechanism', mechanism.id ) );
    }

	function handleXml( xml : XML ) {
		switch xml.name {
		case 'challenge':
			var response = mechanism.createChallengeResponse( xml.value );
			stream.sendString( XML.create( 'response', Base64.encode( Bytes.ofString( response ), true ) ).set( 'xmlns', XMLNS ) );
		case 'failure':
			var info : String = null;
			var text : String = null;
			for( e in xml.elements() ) {
				switch e.name {
				case 'text': text = e.value;
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
		if( stream.serverFeatures.exists( 'bind' ) ) {
			var iq = new IQ( set, '<bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"/>' );
			if( mechanism.id != AnonymousMechanism.NAME ) iq.payload.append( XML.create( 'resource', resource ) );
			stream.sendQuery( iq, function(res){
				switch res {
				case result(r):
					stream.jid.resource = resource;
					if( stream.serverFeatures.exists( 'session' ) ) {
						stream.sendQuery( IQ.set( '<session xmlns="urn:ietf:params:xml:ns:xmpp-session"/>' ), function(res){
							callback( switch res {
								case result(r): null;
								case error(e): e;
							});
						});
					}
				case error(e):
					trace( e ); //TODO
				}
			});
		} else {
			callback( null );
		}
	}

	/*
	public static function authenticate( stream : Stream, password : String, mechanisms : Array<Mechanism> ) {
	}
	*/
}
