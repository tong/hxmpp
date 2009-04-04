package jabber;

private typedef Listener = {
	var nodeName : String;
	var xmlns : String;
	var handler : xmpp.Message->Xml->Void;
	var type : Class<xmpp.pep.Event>;
}

/**
	Listener for incoming personal events.
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
		stream.addCollector( new jabber.stream.PacketCollector( [ cast new xmpp.filter.MessageFilter( xmpp.MessageType.normal ),
																  cast new xmpp.filter.PacketPropertyFilter( xmpp.PubSubEvent.XMLNS, "event" ) ],
																  handlePersonalEvent, true ) );
	}
	
	/**
		Add listener for the given type.
	*/
	public function add( type : Class<xmpp.pep.Event>, handler : xmpp.Message->Xml->Void ) : Bool {
		var l = getListener( type );
		if( l != null ) return false;
		else {
			var _l = Type.createInstance( type, [] );
			listeners.add( { nodeName : _l.nodeName, xmlns : _l.xmlns, handler : handler, type : type } );
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
		var i = Type.createInstance( type, [] );
		for( l in listeners )
			//if( l.nodeName == i.nodeName && l.xmlns == i.xmlns )
			if( l.type == type ) return l;
		return null;
	}
	
	public function iterator() : Iterator<Listener> {
		return listeners.iterator();
	}
	
	
	function handlePersonalEvent( m : xmpp.Message ) {
		//TODO? var event = xmpp.pep.Event.fromMessage();
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
				if( l.nodeName == i.payload.nodeName && l.xmlns == i.payload.get( "xmlns" ) )
					l.handler( m, i.payload );
	}
	
}
