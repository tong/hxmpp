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
	<a href="http://xmpp.org/extensions/xep-0012.html">XEP-0012: Last Activity</a><br/>
*/
class LastActivity {
	
	public static var XMLNS = "jabber:iq:last";
	
	public var seconds : Int;
	
	public function new( ?seconds : Int = -1 ) {
		this.seconds = seconds;
	}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS );
		if( seconds >= 0 ) x.set( "seconds", Std.string( seconds ) );
		return x;
	}
	
	public static inline function parse( x : Xml ) : LastActivity {
		return new LastActivity( parseSeconds( x ) );
	}
	
	/**
		Parses/Returns the time value of the given IQ query xml.
	*/
	public static inline function parseSeconds( x : Xml ) : Int {
		return Std.parseInt( x.get( "seconds" ) );
	}
	
}
