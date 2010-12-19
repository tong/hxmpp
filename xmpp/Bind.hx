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

/**
	IQ extension used to bind a resource to a stream.<br/>
	<a href="http://xmpp.org/rfcs/rfc3920.html#bind">RFC3920#bind</a>
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
	#if flash // TODO haXe 2.06 fukup
		x.set( "_xmlns_", XMLNS );
	#else
		x.set( "xmlns", XMLNS );
	#end
		if( resource != null ) x.addChild( XMLUtil.createElement( "resource", resource ) );
		if( jid != null ) x.addChild( XMLUtil.createElement( "jid", jid ) );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.Bind {
		var b = new Bind();
		for( e in x.elements() ) {
			var v = e.firstChild().nodeValue;
			switch( e.nodeName ) {
			case "resource" : b.resource = v;
			case "jid" : b.jid = v;
			}
		}
		return b;
	}
	
}
