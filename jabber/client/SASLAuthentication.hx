package jabber.client;

import jabber.core.PacketCollector;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.filter.PacketNameFilter;
import xmpp.filter.PacketOrFilter;


/**
	Responsible for authenticating a client account using SASL, binding the resource to the connection
	and establishing a session with the server.
	
	http://xmpp.org/rfcs/rfc3920.html#sasl
	http://xmpp.org/rfcs/rfc3920.html#bind
	
	http://www.ietf.org/mail-archive/web/isms/current/msg00063.html	
*/
class SASLAuthentication {

	public dynamic function onFailed( s : SASLAuthentication )  : Void;
	public dynamic function onNegotiated( s : SASLAuthentication ) : Void;
	public dynamic function onSuccess( s : SASLAuthentication ) : Void; //-> stream, jid, resource
	
	public var stream(default,null) : Stream;
	public var handshake(default,null) : net.sasl.Handshake;
	public var resource(default,null) : String;
	public var active(default,null) : Bool;
	
	var negotiated : Bool;
	var availableMechanisms : Array<String>;
	var col_error : PacketCollector;
	var col_challenge : PacketCollector;
	var col_success : PacketCollector;
	
	
	public function new( stream : Stream, mechanisms : Iterable<net.sasl.Mechanism> ) {
		
		var x = stream.server.features.get( "mechanisms" );
		if( x == null ) throw "Server does not support SASL";
		availableMechanisms = xmpp.SASL.parseMechanisms( x );
		
		this.stream = stream;
		
		active = false;
		negotiated = false;
		handshake = new net.sasl.Handshake();
		for( m in mechanisms ) handshake.mechanisms.push( m );
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
			for( availableMechanism in availableMechanisms ) {
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
		#if JABBER_DEBUG
		trace( "Used SASL mechanism: "+handshake.mechanism.id );
		#end
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
		col_error = new PacketCollector( [cast errorFilters], handleSASLError, false );
		stream.addCollector( col_error );

		// collect challenge packets
		col_challenge = new PacketCollector( [cast new PacketNameFilter( ~/challenge/ )], handleSASLChallenge, true );
		stream.addCollector( col_challenge );
		
		// collect success packet
		col_success = new PacketCollector( [cast new PacketNameFilter( ~/success/ )], handleSASLSuccess );
		stream.addCollector( col_success );
		
		// send init auth
		var t = handshake.mechanism.createAuthenticationText( stream.jid.node, stream.jid.domain, password );
		if( t != null ) t = util.Base64.encode( t );
		return stream.sendData( xmpp.SASL.createAuthXml( handshake.mechanism.id, t ).toString() );
	}
	
	
	function handleSASLChallenge( p : xmpp.Packet ) {
		var c = p.toXml().firstChild().nodeValue;
		// create/send challenge response
		var enc = util.Base64.encode( handshake.getChallengeResponse( c ) );
		stream.sendData( xmpp.SASL.createResponseXml( enc ).toString() );
	}
	
	function handleSASLError( p : xmpp.Packet ) {
		active = false;
		onFailed( this );
	}
	
	function handleSASLSuccess( p : xmpp.Packet ) {
		//stream.sasl.negotiated = true;
		negotiated = true;
		stream.version = false;
		stream.open(); // reopen stream
	}
	
	function handleStreamOpen( s : Stream ) {
		if( negotiated ) {
			// bind resource
			var iq = new IQ( IQType.set );
			iq.ext = new xmpp.Bind( resource );
			stream.sendIQ( iq, handleBind );
		}
	}
	
	function handleBind( iq : IQ ) {
		switch( iq.type ) {
			case IQType.result :
				/*
				// TODO required ?
				var b = xmpp.Bind.parse( iq.ext.toXml() );
				if( jabber.util.JIDUtil.parseResource( b.jid ) != resource ) {
					throw "Unexpected resource bound ?";
				}
				*/
				onSuccess( this );
					
			case IQType.error :
				trace( "Unable to bind resource" );
				//TODO
				active = false;
				onFailed( this );
		}
		cleanup();
	}
	
	function cleanup() {
		active = false;
		stream.removeCollector( col_challenge );
		stream.removeCollector( col_success );
		stream.removeCollector( col_error );
		//col_challenge = col_success = collector_error = null;
	}
	
}
