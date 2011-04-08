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

using xmpp.XMLUtil;

/**
	<a href="http://www.xmpp.org/extensions/xep-0202.html">XEP 202 - EntityTime</a>
*/
class EntityTime {
	
	public static var XMLNS = "urn:xmpp:time";
	
	/**
		 The UTC time according to the responding entity.
		 The format conforms to the dateTime profile specified in XEP-0082 (http://www.xmpp.org/extensions/xep-0082.html)
		 and MUST be expressed in UTC.
	*/
	public var utc : String; // (default,setUTC) : String;
	
	/**
		The entity's numeric time zone offset from UTC.
		The format conforms to the Time Zone Definition (TZD) specified in XEP-0082 (http://www.xmpp.org/extensions/xep-0082.html).
	*/
	public var tzo : String;// (default,setTZO) : String;
	
	
	public function new( ?utc : String, ?tzo : String ) {
		this.utc = utc;
		this.tzo = tzo;
	}
	
/*
	function setTZO( t : String ) : String {
		//if( !xmpp.DateTime.isValid( t ) ) return tzo = null;
		return tzo = t;
	}
	function setUTC( t : String ) : String {
		if( !xmpp.DateTime.isValid( t ) ) return utc = null;
		return utc = t;
	}
	*/
	
	public function toXml() : Xml {
		var x = Xml.createElement( "time" );
		x.ns( XMLNS );
		if( utc != null ) x.addChild( XMLUtil.createElement( "utc", utc ) );
		if( tzo != null ) x.addChild( XMLUtil.createElement( "tzo", tzo ) );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.EntityTime {
		var t = new EntityTime();
		for( c in x.elements() ) {
			switch( c.nodeName ) {
			case "tzo" : t.tzo = c.firstChild().nodeValue;
			case "utc" : t.utc = c.firstChild().nodeValue;
			}
		}
		return t;
	}
	
}
