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

private typedef Listener = {
	//var nodeName : String;
	var xmlns : String;
	var handler : xmpp.Message->Xml->Void;
	var type : Class<xmpp.pep.Event>;
}

/**
	Listener for incoming personal events from other entities.
	<a href="http://xmpp.org/extensions/xep-0163.html">XEP-0163: Personal Eventing Protocol</a>
*/
class PersonalEventListener {
	
	/** Optional to collect ALL personal events */
	//public dynamic function onEventMessage( m : xmpp.Message ) : Void;
	
	public var stream(default,null) : Stream;
	
	var listeners : List<Listener>;
	
	public function new( stream : Stream ) {
		this.stream = stream;
		listeners = new List();
		stream.collect( [ cast new xmpp.filter.MessageFilter( xmpp.MessageType.normal ), //TODO hm ?
						  cast new xmpp.filter.PacketPropertyFilter( xmpp.PubSubEvent.XMLNS, "event" ) ],
						handlePersonalEvent, true );
	}
	
	/**
		Add listener for the given type.
	*/
	public function add( t : Class<xmpp.pep.Event>, handler : xmpp.Message->Xml->Void ) : Bool {
		var l = getListener( t );
		if( l != null )
			return false;
		else {
			listeners.add( { xmlns : untyped t.XMLNS, handler : handler, type : t } );
			return true;
		}
	}
	
	/**
		Remove listener for the given type.
	*/
	public function remove( type : Class<xmpp.pep.Event> ) : Bool {
		var l = getListener( type );
		if( l == null ) return false;
		return listeners.remove( l );
	}
	
	/**
		Clear all listeners.
	*/
	public function clear() {
		listeners = new List();
	}
	
	/**
		Returns the listeners for the given type.
	*/
	public function getListener( type : Class<xmpp.pep.Event> ) : Listener {
		for( l in listeners )
			if( l.type == type ) return l;
		return null;
	}
	
	public function iterator() : Iterator<Listener> {
		return listeners.iterator();
	}
	
	function handlePersonalEvent( m : xmpp.Message ) {
		trace("handlePersonalEventhandlePersonalEvent");
		// var event = xmpp.pep.Event.fromMessage();
		//onEventMessage( m );
		var event : xmpp.PubSubEvent = null;
		for( p in m.properties ) {
			if( p.nodeName == "event" ) {
				event = xmpp.PubSubEvent.parse( p );
				break;
			}
		}
		for( i in event.items )
			for( l in listeners )
				if( /*l.nodeName == i.payload.nodeName &&*/ l.xmlns == i.payload.get( "xmlns" ) )
					l.handler( m, i.payload );
	}
	
}
