/*
 * Copyright (c) disktree.net
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

/**
	Client-to-Server XMPP stream (http://xmpp.org/rfcs/rfc6120.html#examples-c2s)
*/
class Stream extends jabber.Stream {

	/* IANA registered "xmpp-client" port */
	public static inline var PORT = 5222;

	/**/
	public static inline var PORT_SECURE = 5223;

	/** The default port for socket connections if not specified */
	public static var defaultPort = PORT;

	/** The default port for secure socket connections */
	public static var defaultPortSecure = PORT_SECURE;
	
	var version : Bool;
	
	public function new( cnx : StreamConnection, ?maxBufSize : Int ) {
		super( cnx, maxBufSize );
		this.jid = jid;
		version = true;
	}
	
	override function handleConnect() {
		var wasOpen = status == StreamStatus.open;
		status = connecting;
		if( !cnx.http ) {
			send( xmpp.Stream.createOpenXml( xmpp.Stream.CLIENT, jid.domain, version, lang ) );
			if( !wasOpen )
				cnx.read( true ); // Start reading input
		} else {
			if( cnx.connected ) {
				//server.features = new Hash(); // clear the server features offered (?)
				cnx.connect(); // Restart HTTP/BOSH
			}
		}
	}
	
	override function processStreamInit( s : String ) : Bool {
		if( cnx.http ) { //TODO remove
			#if xmpp_debug jabber.XMPPDebug.i(s); #end
			var x : Xml = null;
			try x = Xml.parse( s ).firstElement() catch( e : Dynamic ) {
				return false;
			}
			for( e in ((x.nodeName == "body") ? x.firstElement() : x).elements() )
				serverFeatures.set( e.nodeName, e );
			//parseServerStreamFeatures( ( x.nodeName == "body" ) ? x.firstElement() : x );
			status = StreamStatus.open;
			handleStreamOpen();
			return true;
		} else {
			var r = ~/^(<\?xml) (.)+\?>/;
			if( r.match(s) ) s = r.matchedRight();
			var sei = s.indexOf( ">" );
			if( sei == -1 )
				return false;
			if( id == null ) { // Parse open stream
				var str = s.substr( 0, sei )+" />";
				var sx = Xml.parse( str ).firstElement();
				id = sx.get( "id" );
				if( !version ) {
					status = StreamStatus.open;
					//cnx.reset();
					handleStreamOpen();
					return true;
				}
			}
			//TODO check for stream errors
			//Example: <stream:error xmlns:stream="http://etherx.jabber.org/streams"><xml-not-well-formed xmlns="urn:ietf:params:xml:ns:xmpp-streams"/></stream:error>
			if( id == null ) {
				close( true );
				onClose( "no stream id" );
				return false;
			}
			if( !version ) {
				status = StreamStatus.open;
				handleStreamOpen();
				return true;
			}
		}
		var sfi = s.indexOf( "<stream:features>" );
		if( sfi != -1 ) {
			
			var sf = s.substr( sfi );
			
			#if flash // TODO haxe 2.06 xml namespace fuckup
			sf = StringTools.replace( sf, "stream:features", "stream_features" );
			#end

			var x : Xml;
			try x = Xml.parse( sf ).firstElement() catch( e : Dynamic ) {
				return false;
			}
			for( e in x.elements() )
				serverFeatures.set( e.nodeName, e );
		
			#if xmpp_debug jabber.XMPPDebug.i( s ); #end
			
			if( cnx.secure && !cnx.secured && serverFeatures.get( "starttls" ) != null ) {
				status = starttls;
				send( '<starttls xmlns="urn:ietf:params:xml:ns:xmpp-tls"/>' );
			} else {
				status = StreamStatus.open;
				handleStreamOpen();
			}
			return true;
		}
		return false;
		
	}
	
}
