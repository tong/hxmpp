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

import jabber.stream.Connection;

/**
	Base for client XMPP streams.<br/>
*/
class Stream extends jabber.Stream {
	
	public static inline var PORT_STANDARD = 5222;
	public static inline var PORT_SECURE_STANDARD = 5223;
	public static var defaultPort = PORT_STANDARD;
	
	//TODO public var tls(default,null) : Bool;
	public var jid(default,null) : jabber.JID;
	
	public function new( jid : jabber.JID, cnx : Connection, version : Bool = true ) {
		//super( cnx, jid );//TODO
		super( cnx );
		this.jid = jid;
		this.version = version;
		//this.tls = tls;
	}
	
	override function getJIDStr() : String {
		return jid.toString();
	}
	
	override function processStreamInit( t : String, buflen : Int ) : Int {
		// TODO remove HACK
		//if( Type.getClassName( Type.getClass( cnx ) ) == "jabber.BOSHConnection" ) {
		if( isBOSH ) {
			//TODO
			var sx = Xml.parse( t ).firstElement();
			var sf = sx.firstElement();
			parseStreamFeatures( sf );
			status = jabber.StreamStatus.open;
			onOpen();
			return buflen;	
		} else {
			var sei = t.indexOf( ">" );
			if( sei == -1 ) {
				return 0;
			}
			if( id == null ) { // parse open stream
				var s = t.substr( 0, sei ) + " />";
				#if XMPP_DEBUG
				jabber.XMPPDebug.inc( s );
				#end
				var sx = Xml.parse( s ).firstElement();
				id = sx.get( "id" );
				if( !version ) {
					status = jabber.StreamStatus.open;
					onOpen();
					return buflen;
				}
			}
			if( id == null )
				throw "Invalid XMPP stream, no ID";
			if( !version ) {
				status = jabber.StreamStatus.open;
				onOpen();
				return buflen;
			}
		}
		var sfi = t.indexOf( "<stream:features>" );
		var sf = t.substr( t.indexOf( "<stream:features>" ) );
		if( sfi != -1 ) {
			try {
				var sfx = Xml.parse( sf ).firstElement();
				parseStreamFeatures( sfx );
				#if XMPP_DEBUG
				jabber.XMPPDebug.inc( sfx.toString() );
				#end
				status = jabber.StreamStatus.open;
				onOpen();
				return buflen;
			} catch( e : Dynamic ) {
				return 0;
			}
		}
		return buflen;
		//return throw "Never reached";
	}
	
	override function connectHandler() {
		status = jabber.StreamStatus.pending;
		// TODO avoid HACK
		if( Type.getClassName( Type.getClass( cnx ) ) != "jabber.BOSHConnection" ) {
			sendData( xmpp.Stream.createOpenStream( xmpp.Stream.XMLNS_CLIENT, jid.domain, version, lang ) );
			cnx.read( true ); // start reading input
		} else {
			if( cnx.connected )
				cnx.connect(); // restart bosh
		}
	}
	
	/*
	override function disconnectHandler() {
		id = null;
	}
	*/
	
	function parseStreamFeatures( x : Xml ) {
		for( e in x.elements() )
			server.features.set( e.nodeName, e );
	}
}
