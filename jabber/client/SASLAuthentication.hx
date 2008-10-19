package jabber.client;

import jabber.core.PacketCollector;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.filter.PacketNameFilter;
import xmpp.filter.PacketOrFilter;


/*
typedef BindEvent = {
	var stream : Stream;
	var jid : String;
	var resource : String;
}
// hmmm
class AuthEvent {
	
	public var stream : Stream;
	
	public function new() {
		super();
	}
}
*/


/**
	Responsible authenticating a client account using SASL, binding the resource to
	the connection and establishing a session with the server.
	
	http://xmpp.org/rfcs/rfc3920.html#sasl
	http://xmpp.org/rfcs/rfc3920.html#bind
	
*/
class SASLAuthentication {

	public dynamic function onFailed( stream : Stream ) {}
	//public dynamic function onSASLComplete( stream : Stream ) {}
	public dynamic function onSuccess( stream : Stream ) {} //-> stream, jid, resource
	
	public var stream(default,null) : Stream;
	public var handshake(default,null) : net.sasl.Handshake;
	public var resource(default,null) : String;
	public var active(default,null) : Bool;
	
	var collector_error : PacketCollector;
	var collector_challenge : PacketCollector;
	var collector_success : PacketCollector;
	
	
	public function new( stream : Stream ) {
		
		this.stream = stream;
		
		active = false;
		handshake = new net.sasl.Handshake();
	}
	
	
	/**
		Inits SASL authentication.
		Returns false if no compatible sasl mechanism was found.
	*/
	public function authenticate( password : String, ?resource : String ) : Bool {
		
		if( active ) return false;
		this.resource = resource; 
		
		// relay the stream opn event TODO:save old handler and reassign on authentication success/fail
		stream.onOpen = handleStreamOpen;
		
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
			return false;
		}
		
		active = true;
		
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
		collector_error = new PacketCollector( [cast errorFilters], handleSASLError, false );
		stream.collectors.add( collector_error );
		
		// collect challenge packets
		collector_challenge = new PacketCollector( [cast new PacketNameFilter( ~/challenge/ )], handleSASLChallenge, true );
		stream.collectors.add( collector_challenge );
		
		// collect success packet
		collector_success = new PacketCollector( [cast new PacketNameFilter( ~/success/ )], handleSASLSuccess );
		stream.collectors.add( collector_success );
		
		// send auth
		var text = handshake.mechanism.createAuthenticationText( stream.jid.node, stream.jid.domain, password );
		if( text != null ) text = haxe.BaseCode.encode( text, util.StringUtil.BASE64 );
		stream.sendData( xmpp.SASL.createAuthXml( handshake.mechanism.id, text ).toString() );
		
		return true;
	}
	
	
	function handleSASLChallenge( p : xmpp.Packet ) {
		var c = p.toXml().firstChild().nodeValue;
		// create challenge response
		var response = handshake.getChallengeResponse( c );
		// send challenge response
		stream.sendData( xmpp.SASL.createResponseXml( haxe.BaseCode.encode( response, util.StringUtil.BASE64 ) ).toString() );
	}
	
	function handleSASLError( p : xmpp.Packet ) {
		trace( "handle SASL ERROR "+p );
	}
	
	function handleSASLSuccess( p : xmpp.Packet ) {
		stream.sasl.negotiated = true;
		stream.open(); // reopen stream
	}
	
	function handleStreamOpen( s : Stream ) {
		if( stream.sasl.negotiated ) {
			trace("STREAM REPOPENED .....................");
			// bind resource
			var iq = new IQ( IQType.set );
			iq.ext = new xmpp.Bind( resource );
			stream.sendIQ( iq, handleBind );
		}
	}
	
	function handleBind( iq : IQ ) {
		cleanup();
		switch( iq.type ) {
			case IQType.result :
				var b = xmpp.Bind.parse( iq.ext.toXml() );
				//TODO
				
				onSuccess( stream );
					
			case IQType.error : 
				trace( "TODO resource bind error" );
				//e.error = xmpp.Error.parsePacket( iq );
				//onFailed( e );
		}
	}
	
	function cleanup() {
		active = false;
		stream.collectors.remove( collector_challenge );
		stream.collectors.remove( collector_success );
		stream.collectors.remove( collector_error );
		//collector_challenge = collector_success = collector_error = null;
	}
	
}
