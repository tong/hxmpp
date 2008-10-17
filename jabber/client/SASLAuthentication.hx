package jabber.client;

import jabber.core.PacketCollector;
import xmpp.filter.PacketNameFilter;
import xmpp.filter.PacketOrFilter;


//enum SASLEvent {
//}


/**
	Responsible authenticating the user using SASL, binding the resource to
	the connection and establishing a session with the server.
*/
class SASLAuthentication {

	public dynamic function onSuccess( s : Stream ) {}
	public dynamic function onFailed( s : Stream ) {}
	
	public var stream(default,null) : Stream;
	public var handshake(default,null) : net.sasl.Handshake;
	
	var errorCollector : PacketCollector;
	var challengeCollector : PacketCollector;
	var successCollector : PacketCollector;
	
	
	public function new( stream : Stream ) {
		
		this.stream = stream;

		handshake = new net.sasl.Handshake();
	}
	
	
	/**
		Inits SASL authentication.
	*/
	public function authenticate( password : String, ?resource : String ) {
		
		trace("locating mechanism");
		//handshake.mechanism = new net.sasl.MD5Mechanism();
		//handshake.mechanism = new net.sasl.PlainMechanism();
		handshake.mechanism = new net.sasl.AnonymousMechanism();
		
		//TODO
		// locate mechanism to use.
		if( handshake.mechanism == null ) {
			var mechanism_id : String = null;
			for( availableMechanism in stream.sasl.availableMechanisms ) {
				trace( availableMechanism );
				/*
				var m = stream.sasl.implementedMechanisms.get( availableMechanism );
				if( m != null ) {
					mechanism_id = availableMechanism;
					handshake.mechanism = handshake.createMechanism( m );
					break;
				}
				*/
			}
		}
		if( handshake.mechanism == null ) {
			trace( "No matching SASL mechanism found." );
			return;
		}
		
		// collect errors, failures,..
		var errorFilters = new PacketOrFilter();
		// TODO replace with regular expression.
		errorFilters.add( new PacketNameFilter( ~/failure/ ) ); //?
		errorFilters.add( new PacketNameFilter( ~/not-authorized/ ) );
		errorFilters.add( new PacketNameFilter( ~/aborted/ ) );
		errorFilters.add( new PacketNameFilter( ~/incorrect-encoding/ ) );
		errorFilters.add( new PacketNameFilter( ~/invalid-authzid/ ) );
		errorFilters.add( new PacketNameFilter( ~/invalid-mechanism/ ) );
		errorFilters.add( new PacketNameFilter( ~/mechanism-too-weak/ ) );
		errorFilters.add( new PacketNameFilter( ~/temporary-auth-failure/ ) );
		errorCollector = new PacketCollector( [cast errorFilters], handleError, false );
		stream.collectors.add( errorCollector );
		
		// collect challenge packets
		challengeCollector = new PacketCollector( [cast new PacketNameFilter( ~/challenge/ )], handleChallenge, true );
		stream.collectors.add( challengeCollector );
		
		// collect success packet
		successCollector = new PacketCollector( [cast new PacketNameFilter( ~/success/ )], handleSuccess );
		stream.collectors.add( successCollector );
		
		// send auth
		var text = handshake.mechanism.createAuthenticationText( stream.jid.node, stream.jid.domain, password );
		if( text != null ) text = haxe.BaseCode.encode( text, util.StringUtil.BASE64 );
		stream.sendData( xmpp.SASL.createAuthXml( handshake.mechanism.id, text ).toString() );
	}
	
	
	function handleChallenge( p : xmpp.Packet ) {
		var c = p.toXml().firstChild().nodeValue;
		var response = handshake.getChallengeResponse( c );
		// send challenge response
		stream.sendData( xmpp.SASL.createResponseXml( haxe.BaseCode.encode( response, util.StringUtil.BASE64 ) ).toString() );
	}
	
	function handleError( p : xmpp.Packet ) {
		trace( "handle SASL ERROR "+p );
	}
	
	function handleSuccess( p : xmpp.Packet ) {
		//cleanup();
		//onSuccess( stream );
		trace("SASL SUCCESS, procceed with resource binding.");
		stream.sasl.negotiated = true;
		//stream.open();
	}
	
	function cleanup() {
		stream.collectors.remove( challengeCollector );
		stream.collectors.remove( successCollector );
		stream.collectors.remove( errorCollector );
	}
	
}
