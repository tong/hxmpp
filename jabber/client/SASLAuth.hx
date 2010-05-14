/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package jabber.client;

import jabber.stream.PacketCollector;
import jabber.util.Base64;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.filter.PacketNameFilter;
import xmpp.filter.FilterGroup;

/**
	Responsible for authenticating a client account using SASL,<br/>
	binding the resource to the connection and establishing a session with the server.<br/>
	<a href="http://xmpp.org/rfcs/rfc3920.html#sasl">RFC3920-SASL</a><br/>
	<a href="http://xmpp.org/rfcs/rfc3920.html#bind">RFC3920-BIND</a><br/>
*/
class SASLAuth extends Authentication {

	public dynamic function onNegotiated() : Void;
	
	/** Used SASL method */
	public var mechanism(default,null) : jabber.sasl.TMechanism;
	/** Clients SASL mechanisms */
	public var mechanisms(default,null) : Array<jabber.sasl.TMechanism>;
	/** Available mechanism ids offered by server */
	public var serverMechanisms(default,null) : Array<String>;
	
	var onStreamOpenHandler : Void->Void;
	var c_challenge : PacketCollector;
	var c_fail : PacketCollector;
	var c_success : PacketCollector;
	
	public function new( stream : Stream, mechanisms : Iterable<jabber.sasl.TMechanism> ) {
		var x = stream.server.features.get( "mechanisms" );
		if( x == null )
			throw "Server does't support SASL";
		if( mechanisms == null || Lambda.count( mechanisms ) == 0 )
			throw "Missing SASL mechanisms";
		super( stream );
		this.serverMechanisms = xmpp.SASL.parseMechanisms( x );
		this.mechanisms = new Array();
		for( m in mechanisms )
			this.mechanisms.push( m );
	}
	
	/**
		Inits SASL authentication.<br/>
		Returns false if no compatible SASL mechanism was found.
	*/
	public override function authenticate( password : String, ?resource : String ) : Bool {
		this.resource = resource;
		// update stream's JID resource
		if( stream.jid != null && resource != null )
			stream.jid.resource = resource;
		// locate SASL mechanism to use
		if( mechanism == null ) {
			for( s_mechs in serverMechanisms ) {
				for( m in mechanisms ) {
					if( m.id != s_mechs )
						continue;
					mechanism = m;
					break;
				}
				if( mechanism != null )
					break;
			}
		}
		if( mechanism == null ) {
			#if JABBER_DEBUG trace( "No matching SASL mechanism found.", "warn" ); #end
			return false;
		}
		/*
		if( password == null && handshake.mechanism.id != "ANONYMOUS" ) {
			throw "No password given";
		}
		*/
		c_fail = stream.collect( [cast new PacketNameFilter( xmpp.SASL.EREG_FAILURE )], handleSASLFailed );
		c_success = stream.collect( [cast new PacketNameFilter( ~/success/ )], handleSASLSuccess );
		c_challenge = stream.collect( [cast new PacketNameFilter( ~/challenge/ )], handleSASLChallenge, true );
		// init auth
		var t = mechanism.createAuthenticationText( stream.jid.node, stream.jid.domain, password );
		//TODO?wtf
		if( t != null ) t = Base64.encode( t ); 
		return stream.sendData( xmpp.SASL.createAuthXML( mechanism.id, t ).toString() ) != null;
	}
	
	function handleSASLFailed( p : xmpp.Packet ) {
		removeSASLCollectors();
		onFail();
	}
	
	function handleSASLChallenge( p : xmpp.Packet ) {
		var c = p.toXml().firstChild().nodeValue;
		var r = Base64.encode( mechanism.createChallengeResponse( c ) );
		stream.sendData( xmpp.SASL.createResponseXML( r ).toString() );
	}
	
	function handleSASLSuccess( p : xmpp.Packet ) {
		removeSASLCollectors(); // remove the challenge collector
		onStreamOpenHandler = stream.onOpen; // relay the stream open event
		stream.onOpen = handleStreamOpen;
		onNegotiated();
		//stream.version = false;
//stream.cnx.reset();
		stream.open(); // re-open XMPP stream
		//return p.toString().length;
	}
	
	function handleStreamOpen() {
		stream.onOpen = onStreamOpenHandler;
		//stream.cnx.reset();
		//onStreamOpenHandler = null;
		if( stream.server.features.exists( "bind" ) ) { // bind the resource
			var iq = new IQ( IQType.set );
			iq.x = new xmpp.Bind( ( mechanism.id == "ANONYMOUS" ) ? null : resource );
			stream.sendIQ( iq, handleBind );
		} else {
			onSuccess();
		}
	}
	
	function handleBind( iq : IQ ) {
		switch( iq.type ) {
		case IQType.result :
			/*
			// TODO required ?
			var b = xmpp.Bind.parse( iq.x.toXml() );
			if( jabber.util.JIDUtil.parseResource( b.jid ) != resource ) {
				throw "Unexpected resource bound ?";
			}
			*/
			//onBind();
			var b = xmpp.Bind.parse( iq.x.toXml() );
			var jid = new jabber.JID( b.jid );
			stream.jid.node = jid.node;
			stream.jid.resource = jid.resource;
			if( stream.server.features.exists( "session" ) ) {
				// init session
				var iq = new IQ( IQType.set );
				iq.x = new xmpp.PlainPacket( Xml.parse( '<session xmlns="urn:ietf:params:xml:ns:xmpp-session"/>' ).firstElement() );
				stream.sendIQ( iq, handleSession );
			} else
				onSuccess(); //?
		case IQType.error :
			onFail( new jabber.XMPPError( this, iq ) );
		}
	}
	
	function handleSession( iq : IQ ) {
		switch( iq.type ) {
		case result :
			////onSession();
			onSuccess();
		case error :
			onFail( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
	
	function removeSASLCollectors() {
		stream.removeCollector( c_challenge );
		c_challenge = null;
		stream.removeCollector( c_fail );
		c_fail = null;
		stream.removeCollector( c_success );
		c_success = null;
	}
	
}
