package jabber.client;

import jabber.stream.PacketCollector;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.filter.PacketNameFilter;
import xmpp.filter.PacketOrFilter;


/**
	Responsible for authenticating a client account using SASL, binding the resource to the connection
	and establishing a session with the server.
	
	<a href="http://xmpp.org/rfcs/rfc3920.html#sasl">RFC3920-SASL</a><br>
	<a href="http://xmpp.org/rfcs/rfc3920.html#bind">RFC3920-BIND</a><br>
	http://www.ietf.org/mail-archive/web/isms/current/msg00063.html	
*/
class SASLAuthentication {

	public dynamic function onFailed()  : Void;
	public dynamic function onNegotiated() : Void;
	public dynamic function onSuccess() : Void;
	
	public var stream(default,null) : Stream;
	public var handshake(default,null) : net.sasl.Handshake;
	public var resource(default,null) : String;
	public var active(default,null) : Bool;
	/** Available mechanisms ids */
	public var mechanisms : Array<String>;
	public var negotiated(default,null) : Bool;
	
	var c_error : PacketCollector;
	var c_challenge : PacketCollector;
	var c_success : PacketCollector;
	
	
	public function new( stream : Stream, mechanisms : Iterable<net.sasl.Mechanism> ) {
		
		var x = stream.server.features.get( "mechanisms" );
		if( x == null )
			throw "SASL not supported";
		
		this.mechanisms = xmpp.SASL.parseMechanisms( x );
		this.stream = stream;
		
		active = negotiated = false;
		handshake = new net.sasl.Handshake();
		for( m in mechanisms )
			handshake.mechanisms.push( m );
	}
	
	
	/**
		Inits SASL authentication.
		Returns false if no compatible SASL mechanism was found.
	*/
	public function authenticate( password : String, ?resource : String ) : Bool {
	
		if( active ) return false;
		this.resource = resource; 
		
		// relay the stream open event
		stream.onOpen = handleStreamOpen;
		//TODO!!!!!!!! save old handler and reassign on authentication success/fail
		
		// locate mechanism to use.
		if( handshake.mechanism == null ) {
			for( amechs in mechanisms ) {
				for( m in handshake.mechanisms ) {
					if( m.id != amechs ) continue;
					handshake.mechanism = m;
					break;
				}
				if( handshake.mechanism != null ) break;
			}
		}
		
		if( handshake.mechanism == null ) {
			#if JABBER_DEBUG
			trace( "No matching SASL mechanism found." );
			#end
			return false;
		}
		#if JABBER_DEBUG
		trace( "Used SASL mechanism: "+handshake.mechanism.id );
		#end
		active = true;
		
		// collect errors, failures,..
		var filters = new PacketOrFilter();
		filters.add( new PacketNameFilter( ~/failure/ ) ); //?
		filters.add( new PacketNameFilter( ~/not-authorized/ ) );
		filters.add( new PacketNameFilter( ~/aborted/ ) );
		filters.add( new PacketNameFilter( ~/incorrect-encoding/ ) );
		filters.add( new PacketNameFilter( ~/invalid-authzid/ ) );
		filters.add( new PacketNameFilter( ~/invalid-mechanism/ ) );
		filters.add( new PacketNameFilter( ~/mechanism-too-weak/ ) );
		filters.add( new PacketNameFilter( ~/temporary-auth-failure/ ) );
		c_error = new PacketCollector( [cast filters], handleSASLError, false );
		stream.addCollector( c_error );

		// collect challenge
		c_challenge = new PacketCollector( [cast new PacketNameFilter( ~/challenge/ )], handleSASLChallenge, true );
		stream.addCollector( c_challenge );
		
		// collect success
		c_success = new PacketCollector( [cast new PacketNameFilter( ~/success/ )], handleSASLSuccess );
		stream.addCollector( c_success );
		
		// send init auth
		var t = handshake.mechanism.createAuthenticationText( stream.jid.node, stream.jid.domain, password );
		if( t != null ) t = util.Base64.encode( t );
		return stream.sendData( xmpp.SASL.createAuthXml( handshake.mechanism.id, t ).toString() );
	}
	
	
	function handleSASLChallenge( p : xmpp.Packet ) {
		var c = p.toXml().firstChild().nodeValue;
		// create/send challenge response
		var r = util.Base64.encode( handshake.getChallengeResponse( c ) );
		stream.sendData( xmpp.SASL.createResponseXml( r ).toString() );
	}
	
	function handleSASLError( p : xmpp.Packet ) {
		active = false;
		onFailed();
	}
	
	function handleSASLSuccess( p : xmpp.Packet ) {
		negotiated = true;
		stream.version = false;
		stream.open(); // reopen stream
	}
	
	function handleStreamOpen() {
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
				onSuccess();
					
			case IQType.error :
				trace( "Unable to bind resource" );
				//TODO
				active = false;
				onFailed();
		}
		cleanup();
	}
	
	function cleanup() {
		active = false;
		stream.removeCollector( c_challenge );
		stream.removeCollector( c_success );
		stream.removeCollector( c_error );
		c_challenge = c_success = c_error = null;
	}
	
}
