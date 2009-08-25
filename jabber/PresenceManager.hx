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
	Presence handling wrapper.
*/
class PresenceManager {
	
	public var target : String;
	public var last(default,null) : xmpp.Presence;
	var stream : jabber.Stream;

	public function new( stream : jabber.Stream, ?target : String ) {
		this.stream = stream;
		this.target = target;
	}
	
	/**
	*/
	public function change( ?show : xmpp.PresenceShow, ?status : String, ?priority : Int, ?type : xmpp.PresenceType ) : xmpp.Presence {
		return set( new xmpp.Presence( show, status, priority, type ) );
	}
	
	/**
	*/
	public function set( ?p : xmpp.Presence ) : xmpp.Presence {
		this.last = if( p == null ) new xmpp.Presence() else p;
		if( target != null && last.to == null ) last.to = target;
		return stream.sendPacket( last );
	}
	
}
