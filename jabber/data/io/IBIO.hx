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
package jabber.data.io;

/**
	Abstract base class for inband data in/output.
*/
class IBIO {
	
	public var __onFail : String->Void;
	public var __onComplete : Void->Void;
	
	var stream : jabber.Stream;
	var sid : String;
	var size : Int;
	var seq : Int;
	var active : Bool;
	var bufpos : Int;
	
	function new( stream : jabber.Stream, sid : String, ?size : Int ) {
		this.stream = stream;
		this.sid = sid;
		this.size = size;
		active = true;
		bufpos = 0;
		seq = 0;
	}
	
}
