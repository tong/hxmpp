/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009-2010 http://www.disktree.net
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
import jabber.Stream;
import jabber.stream.Status;
import jabber.stream.Connection;

/**
	Client XMPP stream.
*/
class Stream extends jabber.Stream {
	
	public static inline var PORT = 5222;
	public static inline var PORT_SECURE = 5223;
	
	public static var defaultPort = PORT;
	public static var defaultPortSecure = PORT_SECURE;
	
	var version : Bool;
	
	public function new( cnx : Connection, ?maxBufSize : Int ) {
		super( cnx, maxBufSize );
		this.jid = jid;
		version = true;
	}
	
	override function handleConnect() {
		var wasOpen = status == Status.open;
		status = Status.pending;
		if( !cnx.http ) {
			sendData( xmpp.Stream.createOpenXml( xmpp.Stream.CLIENT, jid.domain, version, lang ) );
			if( !wasOpen ) {
				cnx.read( true ); // start reading input
			}
		} else {
			if( cnx.connected ) {
				//server.features = new Hash(); // clear the server features offered (?)
				cnx.connect(); // restart BOSH
			}
		}
	}
	
	override function processStreamInit( t : String ) : Bool {
		if( cnx.http ) {
			#if XMPP_DEBUG jabber.XMPPDebug.inc( t ); #end
			var x : Xml = null;
			try x = Xml.parse( t ).firstElement() catch( e : Dynamic ) {
				return false;
			}
			parseServerStreamFeatures( ( x.nodeName == "body" ) ? x.firstElement() : x );
			status = Status.open;
			handleStreamOpen();
			return true;
		} else {
			var r = ~/^(<\?xml) (.)+\?>/;
			if( r.match(t) ) t = r.matchedRight();
			var sei = t.indexOf( ">" );
			if( sei == -1 )
				return false;
			if( id == null ) { // parse open stream
				var s = t.substr( 0, sei )+" />";
				var sx = Xml.parse( s ).firstElement();
				id = sx.get( "id" );
				if( !version ) {
					status = Status.open;
					//cnx.reset();
					handleStreamOpen();
					return true;
				}
			}
			if( id == null ) {
				#if JABBER_DEBUG trace( "Invalid XMPP stream, missing ID" ); #end
				close( true );
				onClose( "invalid stream id" );
				return false;
			}
			if( !version ) {
				status = Status.open;
				handleStreamOpen();
				return true;
			}
		}
		var sfi = t.indexOf( "<stream:features>" );
		if( sfi != -1 ) {
			var sf = t.substr( sfi );
			#if flash // TODO haxe 2.06 xml namespace fuckup
			sf = StringTools.replace( sf, "stream:features", "stream_features" );
			#end
			var x : Xml;
			try x = Xml.parse( sf ).firstElement() catch( e : Dynamic ) {
				return false;
			}
			parseServerStreamFeatures( x );
			#if XMPP_DEBUG jabber.XMPPDebug.inc( t ); #end
			if( cnx.secure && !cnx.secured && server.features.get( "starttls" ) != null ) {
				status = Status.starttls;
				sendData( '<starttls xmlns="urn:ietf:params:xml:ns:xmpp-tls"/>' );
			} else {
				status = Status.open;
				handleStreamOpen();
			}
			return true;
		}
		return false; // read more
	}
	
	function parseServerStreamFeatures( x : Xml ) {
		for( e in x.elements() )
			server.features.set( e.nodeName, e );
	}
	
}
