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
	Static methods for creation of XMPP packets for SASL authentication.
*/
class SASL {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-sasl";
	
	/**
	*/
	public static function createAuthXml( mechansim : String, ?text : String ) : Xml {
		if( mechansim == null ) return null;
		//var a = ( text == null ) ? Xml.createElement( "auth" ) : util.XmlUtil.createElement( "auth", text );
		var a = util.XmlUtil.createElement( "auth", text );
		a.set( "xmlns", XMLNS );
		a.set( "mechanism", mechansim );
		return a;
	}
	
	/**
	*/
	public static function createResponseXml( content : String ) : Xml {
		if( content == null ) return null;
		var r = util.XmlUtil.createElement( "response", content );
		r.set( "xmlns", XMLNS );
		return r;
	}
	
	/**
		Parses list of SASL mechanisms from a stream:features packet.
	*/
	public static function parseMechanisms( x : Xml ) : Array<String> {
		var m = new Array<String>();
		for( e in x.elements() ) {
			if( e.nodeName != "mechanism" ) continue;
			m.push( e.firstChild().nodeValue );
		}
		return m;
	}
	
}
