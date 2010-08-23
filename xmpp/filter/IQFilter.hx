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
	Filters IQ packets: namespace/node-name/iq-type
*/
class IQFilter {
	
	public var xmlns : String;
	public var nodeName : String;
	public var iqType : xmpp.IQType;
	
	public function new( ?xmlns : String, ?nodeName : String, ?type : xmpp.IQType ) {
		this.xmlns = xmlns;
		this.nodeName = nodeName;
		this.iqType = type;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		if( p._type != xmpp.PacketType.iq )
			return false;
		var iq : xmpp.IQ = untyped p; //cast( p, xmpp.IQ );
		if( iqType != null && iqType != iq.type )
			return false;
		var x : Xml = null;
		if( xmlns != null ) {
			if( iq.x == null )
				return false;
			x = iq.x.toXml();
			//haXe 2.06 fuckup
			#if flash
			if( xmlns != x.get( "_xmlns_" ) )
			#else
			if( xmlns != x.get( "xmlns" ) )
			#end
				return false;
		}
		if( nodeName != null ) {
			if( iq.x == null )
				return false;
			if( x == null ) x = iq.x.toXml();
			if( nodeName != x.nodeName )
				return false;
		}
		return true;
	}
	
}
