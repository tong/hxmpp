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
	<a href="http://www.xmpp.org/extensions/xep-0138.html">XEP-0138: Stream Compression</a>
*/
class Compression {
	
	public static var XMLNS = xmpp.NS.PROTOCOL+'/compress';
	
	/**
	*/
	public static function createPacket( methods : Array<String> ) : Xml {
		var x = Xml.createElement( "compress" );
		x.set( "xmlns", XMLNS );
		for( m in methods ) x.addChild( util.XmlUtil.createElement( "method", m ) );
		return x;
	}
	
	/**
		Returns an array of parsed compression methods.
	*/
	public static function parseMethods( x : Xml ) : Array<String> {
		var a = new Array<String>();
		for( e in x.elementsNamed( "method" ) ) a.push( e.firstChild().nodeValue );
		return a;
	}
	
}
