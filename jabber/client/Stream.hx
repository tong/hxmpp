/*
 * Copyright (c) 2012, tong, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
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
			#if XMPP_DEBUG jabber.XMPPDebug.i( t ); #end
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
			#if XMPP_DEBUG jabber.XMPPDebug.i( t ); #end
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
