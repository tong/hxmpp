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
package jabber.component;

import jabber.stream.Connection;
import jabber.ServiceDiscoveryListener;
import jabber.util.SHA1;
import xmpp.XMLUtil;

/**
	Component-2-Server XMPP stream.<br/>
	<a href="http://www.xmpp.org/extensions/xep-0114.html">XEP-0114: Jabber Component Protocol</a>
*/
class Stream extends jabber.Stream {
	
	public static inline var PORT_STANDARD = 5275;
	public static var defaultPort = PORT_STANDARD;
	
	/** Called if stream got authenticated and is ready to use */
	public dynamic function onConnect() : Void;
	
	/** XMPP server hostname */
	public var host(default,null) : String;
	/** The subdomain of the server component */
	public var subdomain(default,null) : String;
	/** Full name/address of the server component */
	public var serviceName(getServiceName,null) : String;
	/** Shared secret string used to identify legacy components*/
	public var secret(default,null) : String;
	public var connected(default,null) : Bool;
	public var items(getItems,null) : xmpp.disco.Items; //TODO move into jabber.Stream? 
	public var discoListener(default,null) : ServiceDiscoveryListener;
	
	public function new( cnx : Connection ) {
		super( cnx );
		connected = false;
	}
	
	/**
	*/
	public override function open( host : String, subdomain : String, secret : String, ?identities : Array<xmpp.disco.Identity> ) {
		if( cnx == null )
			throw "No stream connection set";
		if( subdomain == null || subdomain == "" )
			throw "Invalid stream subdomain";
		if( secret == null )
			throw "Invalid stream secret (null)";
		this.host = host;
		this.subdomain = subdomain;
		this.secret = secret;
		items = new xmpp.disco.Items();
		discoListener = new ServiceDiscoveryListener( this, identities );
		cnx.connected ? handleConnect() : cnx.connect();
	}
	
	override function getJIDStr() : String {
		return getServiceName();
	}
	
	function getServiceName() : String {
		if( subdomain == null || host == null ) return null;
		return subdomain+"."+host;
	}
	
	function getItems() : xmpp.disco.Items {
		return items;
	}
	
	override function handleConnect() {
		var t = sendData( xmpp.Stream.createOpenXml( xmpp.Stream.COMPONENT, subdomain ) );
		status = jabber.StreamStatus.pending;
		cnx.read( true );
	}
	
	override function processStreamInit( t : String, len : Int ) {
		if( t.charAt( 0 ) != "<" || t.charAt( t.length-1 ) != ">" )
			return 0;
		t = XMLUtil.removeXmlHeader( t );
		try id = Xml.parse( t+"</stream:stream>" ).firstChild().get( "id" ) catch( e : Dynamic ) {
			trace(e);
			return 0;//-1;
		}
		status = jabber.StreamStatus.open;
		#if XMPP_DEBUG
		jabber.XMPPDebug.inc( t );
		#end
		onOpen();
		collect( [ cast new xmpp.filter.PacketNameFilter( ~/handshake/ ) ], readyHandler, false );
		sendData( XMLUtil.createElement( "handshake", Xml.createPCData( SHA1.encode( id+secret ) ).toString() ).toString() );
		return len;
	}
	
	function readyHandler( p : xmpp.Packet ) {
		connected = true;
		onConnect();
	}
	
}
