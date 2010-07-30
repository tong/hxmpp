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

//TODO!!!!!! remove
class XMPPError extends xmpp.Error {
	
	public var dispatcher(default,null) : Dynamic; //TODO remove
	public var from(default,null) : String;
	
	public function new( dispatcher : Dynamic, p : xmpp.Packet ) {
		var e = p.errors[0];
		if( e == null )
			throw "Packet has no errors";
		//super( e.type, e.code, e.name, e.text );
		super( e.type, e.condition, e.code, e.text );
		this.dispatcher = dispatcher;
		this.from = p.from;
	}
	
	#if JABBER_DEBUG
	public function toString() : String {
		return "XMPPError( "+from+", "+code+", "+text+" )";
	}
	#end
	
}
