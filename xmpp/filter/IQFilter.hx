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
package xmpp.filter;

/**
	Filters IQ packets: namespace/nodename/iqtype
*/
class IQFilter {
	
	public var xmlns : String;
	public var node : String;
	public var type : xmpp.IQType;
	
	public function new( ?xmlns : String, ?type : xmpp.IQType, ?node : String ) {
		this.xmlns = xmlns;
		this.node = node;
		this.type = type;
	}
	
	@:keep public function accept( p : xmpp.Packet ) : Bool {
		if( !Type.enumEq( p._type, xmpp.PacketType.iq ) )
			return false;
		#if as3
		var iq : Dynamic = p;
		#else
		var iq : xmpp.IQ = cast p;
		#end
		if( type != null ) {
			if( !Type.enumEq( type, iq.type ) )
				return false;
		}
		var x : Xml = null;
		if( xmlns != null ) {
			if( iq.x == null )
				return false;
			x = iq.x.toXml();
			if( x.get( "xmlns" ) != xmlns )
				return false;
		}
		if( node != null ) {
			if( iq.x == null )
				return false;
			if( x == null ) x = iq.x.toXml();
			if( node != x.nodeName )
				return false;
		}
		return true;
	}
	
}
