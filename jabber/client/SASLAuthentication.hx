package jabber.client;

import jabber.core.PacketCollector;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.filter.PacketNameFilter;
import xmpp.filter.PacketOrFilter;


/**
	Responsible authenticating a client account using SASL, binding the resource to the connection
	and establishing a session with the server.
	
	http://xmpp.org/rfcs/rfc3920.html#sasl
	http://xmpp.org/rfcs/rfc3920.html#bind
	
	http://www.ietf.org/mail-archive/web/isms/current/msg00063.html	
*/
class SASLAuthentication {

	public dynamic function onFailed( s : SASLAuthentication ) {}
	public dynamic function onNegotiated( s : SASLAuthentication ) {}
	public dynamic function onSuccess( s : SASLAuthentication ) {} //-> stream, jid, resource
	
	public var stream(default,null) : Stream;
	public var handshake(default,null) : net.sasl.Handshake;
	public var resource(default,null) : String;
	public var active(default,null) : Bool;
	
	var clct_error : PacketCollector;
	var clct_challenge : PacketCollector;
	var clct_success : PacketCollector;
	
	
	public function new( stream : Stream ) {
		
		this.stream = stream;
		
		active = false;
		handshake = new net.sasl.Handshake();
		
		// add mechanisms.
		handshake.mechanisms.push( new net.sasl.PlainMechanism() );
	}
	
	
	/**
		Inits SASL authentication.
		Returns false if no compatible sasl mechanism was found.
	*/
	public function authenticate( password : String, ?resource : String ) : Bool {
		
		if( active ) return false;
		this.resource = resource; 
		
		// relay the stream opn event
		stream.onOpen = handleStreamOpen;
		//TODO:save old handler and reassign on authentication success/fail
		
		// locate mechanism to use.
		if( handshake.mechanism == null ) {
			for( availableMechanism in stream.sasl.availableMechanisms ) {
				for( m in handshake.mechanisms ) {
					if( m.id != availableMechanism ) continue;
					handshake.mechanism = m;
					break;
				}
				if( handshake.mechanism != null ) break;
			}
		}
		
		if( handshake.mechanism == null ) {
			trace( "No matching SASL mechanism found." );
			return false;
		}
		active = true;
		
		// collect errors, failures,..
		var errorFilters = new PacketOrFilter();
		errorFilters.add( new PacketNameFilter( ~/failure/ ) ); //?
		errorFilters.add( new PacketNameFilter( ~/not-authorized/ ) );
		errorFilters.add( new PacketNameFilter( ~/aborted/ ) );
		errorFilters.add( new PacketNameFilter( ~/incorrect-encoding/ ) );
		errorFilters.add( new PacketNameFilter( ~/invalid-authzid/ ) );
		errorFilters.add( new PacketNameFilter( ~/invalid-mechanism/ ) );
		errorFilters.add( new PacketNameFilter( ~/mechanism-too-weak/ ) );
		errorFilters.add( new PacketNameFilter( ~/temporary-auth-failure/ ) );
		clct_error = new PacketCollector( [cast errorFilters], handleSASLError, false );
		stream.collectors.add( clct_error );

		// collect challenge packets
		clct_challenge = new PacketCollector( [cast new PacketNameFilter( ~/challenge/ )], handleSASLChallenge, true );
		stream.collectors.add( clct_challenge );
		
		// collect success packet
		clct_success = new PacketCollector( [cast new PacketNameFilter( ~/success/ )], handleSASLSuccess );
		stream.collectors.add( clct_success );
		
		// send init auth
		var t = handshake.mechanism.createAuthenticationText( stream.jid.node, stream.jid.domain, password );
		if( t != null ) t = util.Base64.encode( t );
		return stream.sendData( xmpp.SASL.createAuthXml( handshake.mechanism.id, t ).toString() );
	}
	
	
	function handleSASLChallenge( p : xmpp.Packet ) {
		var c = p.toXml().firstChild().nodeValue;
		// create/send challenge response
		var enc = util.Base64.encode( handshake.getChallengeResponse( c ) );
	//	enc = util.Base64.removeNullbits( enc );
		stream.sendData( xmpp.SASL.createResponseXml( enc ).toString() );
	}
	
	function handleSASLError( p : xmpp.Packet ) {
		onFailed( this );
	}
	
	function handleSASLSuccess( p : xmpp.Packet ) {
		stream.sasl.negotiated = true;
		stream.version = null;
		stream.open(); // reopen stream
	}
	
	function handleStreamOpen( s : Stream ) {
		if( stream.sasl.negotiated ) {
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
				// TODO required ?
				var b = xmpp.Bind.parse( iq.ext.toXml() );
				if( jabber.util.JIDUtil.parseResource( b.jid ) != resource ) {
					throw "Unexpected resource bound ?";
				}
				onSuccess( this );
					
			case IQType.error :
				trace( "Unable to bind resource" );
				//TODO
				//e.error = xmpp.Error.parsePacket( iq );
				onFailed( this );
		}
	}
	
	function cleanup() {
		active = false;
		stream.collectors.remove( clct_challenge );
		stream.collectors.remove( clct_success );
		stream.collectors.remove( clct_error );
		//clct_challenge = clct_success = collector_error = null;
	}
	
}
