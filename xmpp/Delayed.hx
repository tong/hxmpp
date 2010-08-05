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
package xmpp;

typedef PacketDelay = {
	
	/**
		The Jabber ID of the entity that originally sent the XML stanza
		or that delayed the delivery of the stanza (e.g., the address of a multi-user chat room).
	*/
	var from : String;
	
	/**
		The time when the XML stanza was originally sent.
	*/
	var stamp : String;
	
	/**
		Description of the reason for the delay.
	*/
	var description : String;
}

/**
	<a href="http://xmpp.org/extensions/xep-0203.html">XEP-0203: Delayed Delivery</a><br/>
*/
class Delayed {
	
	public static var XMLNS = "urn:xmpp:delay";
	
	public var from : String;
	public var stamp : String;
	public var description : String;
	
	public function new( from : String, stamp : String, ?description : String ) {
		this.from = from;
		this.stamp = stamp;
		this.description = description;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "delay" );
		x.set( "xmlns", XMLNS );
		x.set( "from", from );
		x.set( "stamp", stamp );
		if( description != null )
			x.set( "description", description );
		return x;
	}
	
	/**
		Parses/Returns the packet delay from the properties of the given XMPP packet.
	*/
	public static function fromPacket( p : xmpp.Packet ) : xmpp.PacketDelay {
		for( e in p.properties ) {
			var nodeName = e.nodeName;
			var xmlns = e.get( "xmlns" );
			if( nodeName == "delay" ) {
				var desc : String = null;
				try {
					desc = e.firstChild().nodeValue;
				} catch( e : Dynamic ) {}
				return { from : e.get( "from" ), stamp : e.get( "stamp" ), description : desc };
			} else {
				if( nodeName == "x" && xmlns == "jabber:x:delay" ) {
					var desc : String = null;
					try { desc = e.firstChild().nodeValue; } catch( e : Dynamic ) {}
					return { from : e.get( "from" ), stamp : e.get( "stamp" ), description : desc };
				}
				continue;
			}
		}
		return null;
	}
	
}
