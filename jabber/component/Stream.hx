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
package jabber.component;

import jabber.util.SHA1;
import xmpp.XMLUtil;

/**
	JID of a XMPP component.
*/
@:require(jabber_component)
class ComponentJID {
	
	public var subdomain(default,null) : String;
	public var host(default,null) : String;
	public var s(get,null) : String;
	
	public function new( subdomain : String, host : String ) {
		this.subdomain = subdomain;
		this.host = host;
	}
	
	inline function get_s() : String return toString();
	
	public inline function toString() : String {
		return subdomain+'.'+host;
	}
}

/**
	XMPP server-component stream.
	XEP-0114: Jabber Component Protocol, http://www.xmpp.org/extensions/xep-0114.html
*/
@:require(jabber_component)
class Stream extends jabber.Stream {
	
	public static inline var PORT_STANDARD = 5275;
	public static var defaultPort = PORT_STANDARD;
	
	/** Called if stream got authenticated and is ready to use */
	public dynamic function onReady() {}
	
	/** XMPP server hostname */
//	public var host(default,null) : String;

	/** The subdomain of the server component */
//	public var subdomain(default,null) : String;

	/** Full name/address of the server component */
	public var serviceName(get,null) : String;
	
	/** Shared secret string used to identify legacy components*/
	public var secret(default,null) : String;
	
	/** Indicates if the stream is ready to use */
	public var connected(default,null) : Bool;
	
	/** The service discovery items of the client stream */
	@:isVar public var items(get,null) : xmpp.disco.Items;
	
	/** The service discovery listener of this stream */
	public var discoListener(default,null) : ServiceDiscoveryListener;
	
	public function new( cnx : StreamConnection, ?maxBufSize : Int ) {
		super( cnx, maxBufSize );
		connected = false;
	}
	
	/**
	*/
	public override function open( host : String, subdomain : String, secret : String,
								   ?identities : Array<xmpp.disco.Identity> ) {
		if( cnx == null )
			throw "no stream connection set";
		if( subdomain == null || subdomain == "" )
			throw "invalid subdomain: "+subdomain;
		if( secret == null )
			throw "invalid shared server component secret (null)";
		this.jid = new ComponentJID( subdomain, host );
		this.secret = secret;
		items = new xmpp.disco.Items();
		discoListener = new ServiceDiscoveryListener( this, identities );
		cnx.connected ? handleConnect() : cnx.connect();
	}
	
	function get_serviceName() : String {
		return ( jid.subdomain == null || jid.host == null ) ? null : jid.toString();
	}
	
	inline function get_items() : xmpp.disco.Items {
		return items;
	}
	
	override function handleConnect() {
		sendData( xmpp.Stream.createOpenXml( xmpp.Stream.COMPONENT, jid.toString() ) );
		status = StreamStatus.pending;
		cnx.read( true );
	}
	
	/*
	override function handleDisconnect( ?e : String ) {
		trace(status );
		connected = false;
		if( status != Status.closed ) {
			handleStreamClose( e );
		}
	}
	*/
	
	/*
	override function handleConnectionError( e : String ) {
		connected = false;
		handleStreamClose( e );
	}
	*/
	
	override function processStreamInit( t : String ) : Bool {
		if( t.charAt( 0 ) != "<" || t.charAt( t.length-1 ) != ">" )
			return false;
		var r = ~/^(<\?xml) (.)+\?>/;
		if( r.match(t) ) t = r.matchedRight();
		var i = t.indexOf( ">" );
		if( i == -1 )
			return false;
		t = t.substr( 0, i )+" />";
		var x : Xml = null;
		try x = Xml.parse(t).firstElement() catch(e:Dynamic){
			return false;
		}
		id = x.get('id');
		status = StreamStatus.open;
		#if xmpp_debug jabber.XMPPDebug.i( t ); #end
		handleStreamOpen();
		collect( [new xmpp.filter.PacketNameFilter( ~/handshake/ ) ], readyHandler, false );
		sendData( XMLUtil.createElement( "handshake", Xml.createPCData( SHA1.encode( id+secret ) ).toString() ).toString() );
		return true;
	}
	
	function readyHandler( p : xmpp.Packet ) {
		connected = true;
		onReady();
	}
	
}
