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
