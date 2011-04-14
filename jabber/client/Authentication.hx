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
package jabber.client;

/**
	Abstract client account authentication base.
*/
class Authentication {
	
	public dynamic function onSuccess() : Void;
	public dynamic function onFail( ?e : jabber.XMPPError ) : Void;
	
	public var resource(default,null) : String;
	public var stream(default,null) : Stream;
	
	function new( s : Stream ) {
		this.stream = s;
	}
	
	public function authenticate( password : String, ?resource : String ) : Bool {
		return #if JABBER_DEBUG throw 'abstract method' #else null #end;
	}
	
}
