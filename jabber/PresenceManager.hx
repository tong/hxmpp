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
	public function change( ?type : xmpp.PresenceType, ?show : xmpp.PresenceShow, ?status : String, ?priority : Int ) : xmpp.Presence {
		return set( new xmpp.Presence( type, show, status, priority ) );
	}
	
	/**
	*/
	public function set( ?p : xmpp.Presence ) : xmpp.Presence {
		this.last = if( p == null ) new xmpp.Presence() else p;
		if( target != null && last.to == null ) last.to = target;
		return stream.sendPacket( last );
	}
	
}
