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
	<a href="http://xmpp.org/extensions/xep-0071.html">XEP 0071 - XHTML-IM</a>
*/
class XHTML {
	
	public static var XMLNS = xmpp.Packet.PROTOCOL+"/xhtml-im";
	static var W3NS = "http://www.w3.org/1999/xhtml";
	
	public var body : String;
	
	public function new( body : String ) {
		this.body = body;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "html" );
		x.set( "xmlns", XMLNS );
		x.addChild( Xml.parse( '<body xmlns="'+W3NS+'">'+body+'</body>' ).firstElement() );
		return x;
	}
	
	public static function parse( x : Xml ) : XHTML {
		for( e in x.elementsNamed( "body" ) ) {
			if( e.get( "xmlns" ) == W3NS )
				return new XHTML( parseBody( e ) );
		}
		return null;
	}
	
	/**
		Extracts/Returns the HTML body from a message packet.
	*/
	public static function fromMessage( m : xmpp.Message ) : String {
		for( p in m.properties ) {
			if( p.nodeName == "html" && p.get( "xmlns" ) == XMLNS ) {
				for( e in p.elementsNamed( "body" ) ) {
					return parseBody( e );
				}
			}
		}
		return null;
	}	
	
	static function parseBody( x : Xml ) : String {
		var s = new StringBuf();
		for( x in x ) s.add( x.toString() );
		return s.toString();
	}
	
	/**
		Attaches a HTML body to the properties of the given message packet.
	*/
	public static inline function attach( m : xmpp.Message, t : String ) : xmpp.Message {
		m.properties.push( new XHTML( t ).toXml() );
		return m;
	}
	
	/*
	public static inline function create( t : String ) : Xml {
		return new xmpp.XHTML( t ).toXml();
	}
	*/
	
}
