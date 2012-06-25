/*
 * Copyright (c) 2012, tong, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber;

private typedef Listener = {
	//var nodeName : String;
	var xmlns : String;
	var handler : xmpp.Message->Xml->Void;
	var type : Class<xmpp.PersonalEvent>;
}

/**
	<a href="http://xmpp.org/extensions/xep-0163.html">XEP-0163: Personal Eventing Protocol</a><br/>
	Listener for incoming personal events from other entities.
*/
class PersonalEventListener {
	
	/** Optional to collect ALL events */
	//public dynamic function onEventMessage( m : xmpp.Message ) {}
	
	public var stream(default,null) : Stream;
	
	var listeners : List<Listener>;
	
	public function new( stream : Stream ) {
		//TODO! add to stream features
		this.stream = stream;
		listeners = new List();
		stream.collect( [ new xmpp.filter.MessageFilter(),
						  new xmpp.filter.PacketPropertyFilter( xmpp.PubSubEvent.XMLNS, 'event' ) ],
						handlePersonalEvent, true );
	}
	
	public inline function iterator() : Iterator<Listener> {
		return listeners.iterator();
	}
	
	/**
		Add listener for the given type.
	*/
	public function add( t : Class<xmpp.PersonalEvent>, h : xmpp.Message->Xml->Void ) : Bool {
		var l = getListener( t );
		if( l != null ) {
			return false;
		} else {
			#if !cpp
			listeners.add( { xmlns : untyped t.XMLNS, handler : h, type : t } );
			#else
			//TODO !!!!!!!!
			#end
			return true;
		}
	}
	
	/**
		Remove listener for the given type.
	*/
	public function remove( type : Class<xmpp.PersonalEvent> ) : Bool {
		var l = getListener( type );
		if( l == null )
			return false;
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
	public function getListener( type : Class<xmpp.PersonalEvent> ) : Listener {
		for( l in listeners )
			if( l.type == type )
				return l;
		return null;
	}
	
	function handlePersonalEvent( m : xmpp.Message ) {
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
