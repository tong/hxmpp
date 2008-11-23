package jabber.core;


/**
	Presence handling wrapper.
*/
class PresenceManager {
	
	var stream : jabber.Stream;
	var presence : xmpp.Presence;
	
	public function new( stream : jabber.Stream ) {
		this.stream = stream;
	}
	
	public inline function get() : xmpp.Presence {
		return presence;
	}

	public function change( ?type : xmpp.PresenceType, ?show : String, ?status : String, ?priority : Int ) : xmpp.Presence {
		return set( new xmpp.Presence( type, show, status, priority ) );
	}
	
	public function set( ?p : xmpp.Presence ) {
		if( stream.status != jabber.StreamStatus.open ) return null;
		if( p == presence ) return null;
		presence = if( p == null ) new xmpp.Presence() else p;
		return stream.sendPacket( presence );
	}
	
}
