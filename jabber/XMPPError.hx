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
package jabber;

/**
	Used to dispatch and track XMPP protocol errors.
*/
class XMPPError extends xmpp.Error {
	
	public var from(default,null) : String;
	//TODO reference to the packet (?)
	
	public function new( p : xmpp.Packet ) {
		var e = p.errors[0];
		super( e.type, e.condition, e.code, e.text );
		this.from = p.from;
	}
	
	#if JABBER_DEBUG
	
	public function toString() : String {
		var t = "XMPPError[ "+from+", "+condition+", "+code;
		if( text != null ) t += ", "+text;
		return t+" ]";
	}
	
	#end
	
}
