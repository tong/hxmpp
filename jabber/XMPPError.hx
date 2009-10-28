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

//TODO remove (?)
class XMPPError {
	
	public var dispatcher(default,null) : Dynamic;
	public var from(default,null) : String;
	public var type(default,null) : xmpp.ErrorType;
	public var code(default,null) : Int;
	public var name(default,null) : String;
	public var text(default,null) : String;
	//TODO public var packet(default,null) : xmpp.Packet; // reference to the error type XMPP packet.
	
	public function new( dispatcher : Dynamic, p : xmpp.Packet ) {
		var e = p.errors[0];
		if( e == null )
			throw "Packet has no errors";
		this.dispatcher = dispatcher;
		this.from = p.from;
		type = e.type;
		code = e.code;
		name = e.name;
		text = e.text;
	}
	
	#if JABBER_DEBUG
	public function toString() : String {
		return "XMPPError( "+from+", "+name+", "+code+", "+text+" )";
	}
	#end
	
}
