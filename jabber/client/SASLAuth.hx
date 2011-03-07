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

/**
	Responsible for:
	<ol>
		<li>Authenticating a client account using SASL</li>
		<li>Binding the resource to the connection</li>
		<li>Establishing a session with the server</li>
	</ol>
	<a href="http://xmpp.org/rfcs/rfc3920.html#sasl">RFC3920-SASL</a><br/>
	<a href="http://xmpp.org/rfcs/rfc3920.html#bind">RFC3920-BIND</a><br/>
*/
class SASLAuth extends Authentication {

	public dynamic function onNegotiated() : Void;
	
	/** Used SASL method */
	public var mechanism(default,null) : jabber.sasl.TMechanism;
	/** Clients SASL mechanisms (in prefered order) */
	public var mechanisms(default,null) : Array<jabber.sasl.TMechanism>;
	/** Available mechanisms offered by server */
	public var serverMechanisms(default,null) : Array<String>;
	
	var onStreamOpenHandler : Void->Void;
	var c_challenge : PacketCollector;
	var c_fail : PacketCollector;
	var c_success : PacketCollector;
	
	public function new( stream : Stream, mechanisms : Iterable<jabber.sasl.TMechanism> ) {
		super( stream );
		var x = stream.server.features.get( "mechanisms" );
		if( x == null )
			throw new jabber.error.Error( "Server does not support SASL" );
		if( mechanisms == null || Lambda.count( mechanisms ) == 0 )
			throw new jabber.error.Error( "Missing SASL mechanisms" );
		this.serverMechanisms = xmpp.SASL.parseMechanisms( x );
		this.mechanisms = new Array();
		for( m in mechanisms )
			this.mechanisms.push( m );
	}
	
	/**
		Inits SASL authentication.<br/>
		Returns false if no supported SASL mechanism was offered by the server.
	*/
	public override function authenticate( password : String, ?resource : String ) : Bool {
		this.resource = resource;
		if( stream.jid != null && resource != null ) // update stream's JID resource
			stream.jid.resource = resource;
		if( mechanism == null ) { // locate SASL mechanism to use
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
			#if JABBER_DEBUG trace( 'no supported SASL mechanism found', 'warn' ); #end
			return false;
		}
		c_fail = stream.collect( [cast new PacketNameFilter( xmpp.SASL.EREG_FAILURE )], handleSASLFailed );
		c_success = stream.collect( [cast new PacketNameFilter( ~/success/ )], handleSASLSuccess );
		c_challenge = stream.collect( [cast new PacketNameFilter( ~/challenge/ )], handleSASLChallenge, true );
		// init auth
		var t = mechanism.createAuthenticationText( stream.jid.node, stream.jid.domain, password, stream.jid.resource );
		if( t != null ) t = Base64.encode( t );
		return stream.sendData( xmpp.SASL.createAuth( mechanism.id, t ).toString() ) != null;
	}
	
	function handleSASLFailed( p : xmpp.Packet ) {
		removeSASLCollectors();
		onFail();
	}
	
	function handleSASLChallenge( p : xmpp.Packet ) {
		var c = p.toXml().firstChild().nodeValue;
		var r = Base64.encode( mechanism.createChallengeResponse( c ) );
		stream.sendData( xmpp.SASL.createResponse( r ).toString() );
	}
	
	function handleSASLSuccess( p : xmpp.Packet ) {
		stream.cnx.reset(); // clear connection buffer
		removeSASLCollectors(); // remove the collectors
		onStreamOpenHandler = stream.onOpen; // relay the stream open event
		stream.onOpen = handleStreamOpen;
		onNegotiated();
		//stream.version = false;
		//stream.cnx.reset();
		stream.open( null ); // re-open XMPP stream
		//return p.toString().length;
	}
	
	function handleStreamOpen() {
		stream.onOpen = onStreamOpenHandler;
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
		case result :
			//onBind();
			var b = xmpp.Bind.parse( iq.x.toXml() );
			var p = jabber.JIDUtil.getParts( b.jid );
			stream.jid.node = p[0];
			stream.jid.domain = p[1];
			stream.jid.resource = p[2];
			if( stream.server.features.exists( "session" ) ) { // init session
				var iq = new IQ( IQType.set );
				iq.x = new xmpp.PlainPacket( Xml.parse( '<session xmlns="urn:ietf:params:xml:ns:xmpp-session"/>' ).firstElement() );
				stream.sendIQ( iq, handleSession );
			} else {
				onSuccess();
			}
		case error :
			onFail( new jabber.XMPPError( iq ) );
		default : //
		}
	}
	
	function handleSession( iq : IQ ) {
		switch( iq.type ) {
		case result :
			onSuccess();
		case error :
			onFail( new jabber.XMPPError( iq ) );
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
