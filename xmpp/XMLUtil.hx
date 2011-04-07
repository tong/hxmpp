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
	XML extending utilities.
	using xmpp.XMLUtil;
*/
class XMLUtil {
	
	/**
		@param n Name of xml element to create
		@param t Node content
	*/
	public static function createElement( n : String, t : String ) : Xml {
		var x = Xml.createElement( n );
		x.addChild( Xml.createPCData( t ) );
		return x;
	}
	
	/**
		@param x XML element to attach the create element to
		@param n Name of xml node
		@param t Node content
	*/
	public static function addElement( x : Xml, n : String, t : String ) : Xml {
		x.addChild( createElement( n, t ) );
		return x;
	}
	
}
