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
package xmpp.muc;

class Decline {
	
	public var reason : String;
	public var to : String;
	public var from : String;

	var nodeName : String;
	
	public function new( ?reason : String, ?to : String, ?from : String ) {
		nodeName = "decline";
		this.reason = reason;
		this.to = to;
		this.from = from;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( nodeName );
		if( to != null ) x.set( "to", to );
		if( from != null ) x.set( "to", from );
		if( reason != null ) x.addChild( util.XmlUtil.createElement( "reason", reason ) );
		return x;
	}
	
	//TODO public static function parse( x : Xml ) :  {
	
}
