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

import util.XmlUtil;

/**
	IQ extension used to bind a resource.
*/
class Bind {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-bind";
	
	public var resource : String;
	public var jid : String;
	
	public function new( ?resource : String, ?jid : String) {
		this.resource = resource;
		this.jid = jid;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "bind" );
		x.set( "xmlns", XMLNS );
		if( resource != null )
			x.addChild( XmlUtil.createElement( "resource", resource ) );
		if( jid != null )
			x.addChild( XmlUtil.createElement( "jid", jid ) );
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	public static function parse( x : Xml ) : xmpp.Bind {
		var b = new Bind();
		//Packet.reflectPacketNodes( x, b );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
				case "resource" : b.resource = e.firstChild().nodeValue;
				case "jid" : b.jid = e.firstChild().nodeValue;
			}
		}
		return b;
	}
	
}
