package jabber.client;

import jabber.stream.PacketCollector;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.filter.PacketNameFilter;
import xmpp.filter.PacketOrFilter;

/**
	Responsible for authenticating a client account using SASL, binding the resource to the connection
	and establishing a session with the server.<br>
	<a href="http://xmpp.org/rfcs/rfc3920.html#sasl">RFC3920-SASL</a><br>
	<a href="http://xmpp.org/rfcs/rfc3920.html#bind">RFC3920-BIND</a><br>
	http://www.ietf.org/mail-archive/web/isms/current/msg00063.html
*/
class SASLAuthentication {

	public dynamic function onFailed()  : Void;
	public dynamic function onNegotiated() : Void;
	public dynamic function onSuccess() : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	/** Used SASL method */
	public var handshake(default,null) : net.sasl.Handshake;
	/** Used resource */
	public var resource(default,null) : String;
	/** Available mechanisms ids (from server) */
	public var mechanisms(default,null) : Array<String>;
	//public var negotiated(default,null) : Bool;
	public var stream(default,null) : Stream;
	
	var onStreamOpenHandler : Void->Void;
	var challengeCollector : PacketCollector;
	
	public function new( stream : Stream, mechanisms : Iterable<net.sasl.Mechanism> ) {
		
		var x = stream.server.features.get( "mechanisms" );
		if( x == null )
			throw "Server does't support SASL";
		if( mechanisms == null || Lambda.count( mechanisms ) == 0 )
			throw "No SASL mechanisms given";
			
		this.stream = stream;
		this.mechanisms = xmpp.SASL.parseMechanisms( x );
		
		handshake = new net.sasl.Handshake();
		for( m in mechanisms )
			handshake.mechanisms.push( m );
	}
	
	/**
		Inits SASL authentication.
		Returns false if no compatible SASL mechanism was found.
	*/
	public function authenticate( password : String, ?resource : String ) : Bool {
		
		//TODO
//		if( active )
//			throw "SASL authentication already in progress";
		this.resource = resource; 
		
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
		
		// collect failures
		var f = new PacketOrFilter();
		f.add( new PacketNameFilter( ~/failure/ ) ); //?
		f.add( new PacketNameFilter( ~/not-authorized/ ) );
		f.add( new PacketNameFilter( ~/aborted/ ) );
		f.add( new PacketNameFilter( ~/incorrect-encoding/ ) );
		f.add( new PacketNameFilter( ~/invalid-authzid/ ) );
		f.add( new PacketNameFilter( ~/invalid-mechanism/ ) );
		f.add( new PacketNameFilter( ~/mechanism-too-weak/ ) );
		f.add( new PacketNameFilter( ~/temporary-auth-failure/ ) );
		stream.addCollector( new PacketCollector( [cast f], handleSASLFailed ) );
		// collect success
		stream.addCollector( new PacketCollector( [cast new PacketNameFilter( ~/success/ )], handleSASLSuccess ) );
		// collect challenge
		challengeCollector = new PacketCollector( [cast new PacketNameFilter( ~/challenge/ )], handleSASLChallenge, true );
		stream.addCollector( challengeCollector );
		// send init auth
		var t = handshake.mechanism.createAuthenticationText( stream.jid.node, stream.jid.domain, password );
		if( t != null ) t = util.Base64.encode( t );
		return stream.sendData( xmpp.SASL.createAuthXml( handshake.mechanism.id, t ).toString() ) != null;
	}
	
	
	function handleSASLFailed( p : xmpp.Packet ) {
		onFailed();
	}
	
	function handleSASLChallenge( p : xmpp.Packet ) {
		// create/send challenge response
		var c = p.toXml().firstChild().nodeValue;
		var r = util.Base64.encode( handshake.getChallengeResponse( c ) );
		stream.sendData( xmpp.SASL.createResponseXml( r ).toString() );
	}
	
	function handleSASLSuccess( p : xmpp.Packet ) {
		// remove the challenge collector
		stream.removeCollector( challengeCollector );
		challengeCollector = null;
		// relay the stream open event
		onStreamOpenHandler = stream.onOpen;
		stream.onOpen = handleStreamOpen;
		onNegotiated();
		//stream.version = false;
		stream.open(); // re-open XMPP stream
	}
	
	function handleStreamOpen() {
		//onStreamOpenHandler = null;
		if( stream.server.features.exists( "bind" ) ) {
			// bind the resource
			var iq = new IQ( IQType.set );
			iq.ext = new xmpp.Bind( resource );
			stream.sendIQ( iq, handleBind );
		} else {
			onSuccess(); //?
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
			if( stream.server.features.exists( "session" ) ) {
				// init session
				var iq = new IQ( IQType.set );
				iq.ext = new xmpp.PlainPacket( Xml.parse( '<session xmlns="urn:ietf:params:xml:ns:xmpp-session"/>' ) );
				stream.sendIQ( iq, handleSession );
			} else
				onSuccess(); //?
		case IQType.error :
			onError( new jabber.XMPPError( this, iq ) );
		}
	}
	
	function handleSession( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onSuccess();
		case error : onError( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}

}
