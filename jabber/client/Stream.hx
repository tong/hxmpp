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

import jabber.JID;
import jabber.StreamStatus;
import jabber.stream.Connection;

/**
	Client XMPP stream base.<br/>
*/
class Stream extends jabber.Stream {
	
	public static inline var PORT_STANDARD = 5222;
	public static inline var PORT_STANDARD_SECURE = 5223;
	public static var defaultPort = PORT_STANDARD;
	
	public var jid(default,setJID) : JID;
	
	public function new( ?jid : JID,
						 ?cnx : Connection,
						 ?version : Bool = true ) {
		//__isClient = true;
		if( jid == null ) jid = new JID(null);
		super( cnx );
		this.jid = jid;
		this.version = version;
	}
	
	override function getJIDStr() : String {
		return jid.toString();
	}
	
	function setJID( j : JID ) : JID {
		if( status != StreamStatus.closed )
			throw "Cannot change JID on open stream";
		return jid = j;
	}
		
	override function handleConnect() {
		status = StreamStatus.pending;
		if( !http ) { // TODO avoid HACK
			sendData( xmpp.Stream.createOpenStream( xmpp.Stream.XMLNS_CLIENT, jid.domain, version, lang ) );
			cnx.read( true ); // start reading input
		} else {
			if( cnx.connected ) cnx.connect(); // restart BOSH
		}
	}
		
	/*
	override function disconnectHandler() {
		id = null;
	}
	*/
	
	override function processStreamInit( t : String, buflen : Int ) : Int {
		if( http ) {
			#if XMPP_DEBUG
			jabber.XMPPDebug.inc( t );
			#end
			var x = Xml.parse( t ).firstElement();
			var sf = x.firstElement();
			parseStreamFeatures( sf );
			status = StreamStatus.open;
			onOpen();
			return buflen;	
		} else {
			var sei = t.indexOf( ">" );
			if( sei == -1 ) {
				return 0;
			}
			if( id == null ) { // parse open stream
				var s = t.substr( 0, sei )+" />";
				#if XMPP_DEBUG
				jabber.XMPPDebug.inc( s );
				#end
				var sx = Xml.parse( s ).firstElement();
				id = sx.get( "id" );
				if( !version ) {
					status = StreamStatus.open;
					onOpen();
					return buflen;
				}
			}
			if( id == null ) {
				//TODO throw error
				#if JABBER_DEBUG
				trace( "Invalid XMPP stream, missing ID" );
				#end
				close( true );
				return -1;
			}
			if( !version ) {
				status = StreamStatus.open;
				onOpen();
				return buflen;
			}
		}
		var sfi = t.indexOf( "<stream:features>" );
		var sf = t.substr( sfi );
		if( sfi != -1 ) {
			try {
				var x = Xml.parse( sf ).firstElement();
				parseStreamFeatures( x );
				#if XMPP_DEBUG
				jabber.XMPPDebug.inc( x.toString() );
				#end
				status = StreamStatus.open;
				onOpen();
				return buflen;
			} catch( e : Dynamic ) {
				return 0;
			}
		}
		return buflen;
	}
	
	function parseStreamFeatures( x : Xml ) {
		for( e in x.elements() )
			server.features.set( e.nodeName, e );
	}
	
}
