package jabber;


/**
	Presence handling wrapper.
*/
class PresenceManager {
	
	public var target : String;
	
	var stream : jabber.Stream;
	var presence : xmpp.Presence;


	public function new( stream : jabber.Stream, ?target : String ) {
		this.stream = stream;
		this.target = target;
	}
	
	
	public inline function get() : xmpp.Presence {
		return presence;
	}

	public inline function change( ?type : xmpp.PresenceType, ?show : String, ?status : String, ?priority : Int ) : xmpp.Presence {
		return set( new xmpp.Presence( type, show, status, priority ) );
	}
	
	public function set( ?p : xmpp.Presence ) {
//		if( stream.status != jabber.StreamStatus.open ) return null;
//		if( p == presence ) return null;
		this.presence = if( p == null ) new xmpp.Presence() else p;
		if( target != null ) p.to = target;
		return stream.sendPacket( presence );
	}
	
}
