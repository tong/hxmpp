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

/**
	Base for Component-2-Server XMPP streams.<br/>
	<a href="http://www.xmpp.org/extensions/xep-0114.html">XEP-0114: Jabber Component Protocol</a>
*/
class Stream extends jabber.Stream {
	
	public static inline var PORT_STANDARD = 5275;
	public static var defaultPort = PORT_STANDARD;
	
	/** Dispatched on authentication success */
	public dynamic function onConnect() : Void;
	
	/** Server components host */
	public var host(default,null) : String;
	/** This components subdomain */
	public var subdomain(default,null) : String;
	/** */
	public var serviceName(getServiceName,null) : String;
	/** Shared secret used to identify legacy components*/
	public var secret(default,null) : String;
	/**  */
	public var connected(default,null) : Bool;
	/** */
	public var items(getItems,null) : xmpp.disco.Items; //TODO move into jabber.Stream? ( allowed by clients ? )
	/** */
	public var discoListener(default,null) : ServiceDiscoveryListener;
	
	
	public function new( host : String, subdomain : String, secret : String, cnx : Connection,
						 ?identities : Array<xmpp.disco.Identity> ) {
		if( subdomain == null || subdomain == "" )
			throw "Invalid stream subdomain";
		if( secret == null )
			throw "Invalid stream secret (null)";
		super( cnx );
		this.host = host;
		this.subdomain = subdomain;
		this.secret = secret;
		items = new xmpp.disco.Items();
		connected = false;
		discoListener = new ServiceDiscoveryListener( this, identities );
	}
	
	override function getJIDStr() : String {
		return getServiceName();
	}
	
	function getServiceName() : String {
		if( subdomain == null || host == null )
			return null;
		return subdomain+"."+host;
	}
	
	function getItems() : xmpp.disco.Items {
		return items;
	}
	
	override function connectHandler() {
		var t = sendData( xmpp.Stream.createOpenStream( xmpp.Stream.XMLNS_COMPONENT, subdomain ) );
		#if XMPP_DEBUG
		//jabber.XMPPDebug.out( t );
		#end
		status = jabber.StreamStatus.pending;
		cnx.read( true );
	}
	
	//TODO!!!!!!!!!
	override function processStreamInit( t : String, len : Int ) {
		var i = t.indexOf( ">" );
		if( i == -1 )
			return 0;
		/*
		try {
			var x = Xml.parse( t ).firstChild();
			for( e in x.elements() ) {
				trace(e.nodeName);
				if( e.nodeName == "stream:error" ) {
					trace(e.firstChild().nodeName);
					onClose( e.firstChild().nodeName );
					return -1;
				}
			}
		} catch( e : Dynamic ) {
			trace("ERRORERRORERRORERROR "+e);
		}
		trace(t);
		*/
		//TODO
		id = Xml.parse( t+"</stream:stream>" ).firstChild().get( "id" );
		//..
		status = jabber.StreamStatus.open;
		#if XMPP_DEBUG
		jabber.XMPPDebug.inc( t );
		#end
		onOpen();
		collectors.add( new  jabber.stream.PacketCollector( [ cast new xmpp.filter.PacketNameFilter( ~/handshake/ ) ], readyHandler, false ) );
		sendData( util.XmlUtil.createElement( "handshake", Xml.createPCData( crypt.SHA1.encode( id+secret ) ).toString() ).toString() );
		return len;
	}
	
	function readyHandler( p : xmpp.Packet ) {
		connected = true;
		onConnect();
	}
	
}
