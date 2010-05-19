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
	Filters (just) custom XMPP packets with given nodename expression.
*/
class PacketNameFilter {
	
	public var expr : EReg;
	
	public function new( expr : EReg ) {
		this.expr = expr;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		/* hmm
		if( p._type != xmpp.PacketType.custom ) 
			return false;
		*/
		return expr.match( p.toXml().nodeName );
	}
	
}
