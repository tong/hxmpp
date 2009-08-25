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
package jabber.stream;

import jabber.stream.PacketCollector;

/**
	Abstract base for top level packet listeners ( jabber.PresenceListener, jabber.MessageListener ).
*/
class TopLevelPacketListener<T> {
	
	public dynamic function onPacket( p : T ) : Void;
	
	/**
		Activates/Deactivates packet collecting.
	*/
	public var listen(default,setListening) : Bool;
	/**
		The collector for this listener.
		Extra/Changed filters and settings may get applied.
	*/
	public var collector(default,null) : PacketCollector;
	public var stream(default,null) : jabber.Stream;
	
	function new( stream : jabber.Stream, handler : T->Void, packetType : xmpp.PacketType, ?listen : Bool = true ) {
		
		this.stream = stream;
		this.onPacket = handler;
		
		collector = new PacketCollector( [cast new xmpp.filter.PacketTypeFilter(packetType)], handlePacket, true );
		setListening( listen );
	}
	
	function setListening( v : Bool ) : Bool {
		v ? stream.addCollector( collector ) : stream.removeCollector( collector );
		return listen = v;
	}
	
	// override me if you want
	function handlePacket( p : T ) {
		this.onPacket( p );
	}
	
}
