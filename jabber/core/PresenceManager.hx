package jabber.core;

import jabber.StreamStatus;
import xmpp.Presence;
import xmpp.PresenceType;


/**
	Wrapper base for presence handling.
*/
class PresenceManager {
	
	public var type(getType,setType) : PresenceType;
	public var show(getShow,setShow) : String;
	public var status(getStatus,setShow) : String;
	public var priority(getPriority,setPriority) : Int;
	
	var stream : jabber.core.StreamBase;
	var presence : Presence;
	
	
	public function new( stream : jabber.core.StreamBase ) {
		this.stream = stream;
		presence = new Presence();
	}

	
	function getType() : PresenceType { return presence.type; }
	function setType( v : PresenceType ) : xmpp.PresenceType {
		if( stream.status != StreamStatus.open ) return null;
		if( v == presence.type ) return v;
		presence = new Presence( v );
		stream.sendPacket( presence );
		return v;
	}
	function getShow() : String { return presence.show; }
	function setShow( v : String ) : String {
		if( stream.status != StreamStatus.open ) return null;
		if( v == presence.show ) return v;
		presence = new Presence( null, v );
		stream.sendPacket( presence );
		return v;
	}
	function getStatus() : String { return presence.status; }
	function setStatus( v : String ) : String {
		if( stream.status != StreamStatus.open ) return null;
		if( v == presence.status ) return v;
		presence = new Presence( null, null, v );
		stream.sendPacket( presence );
		return v;
	}
	function getPriority() : Int { return presence.priority; }
	function setPriority( v : Int ) : Int {
		if( stream.status != StreamStatus.open ) return -1;
		if( v == presence.priority ) return v;
		presence = new Presence( null, null, null, v );
		stream.sendPacket( presence );
		return v;
	}
	
	
	/**
		Set the presence.
	*/
	public function set( ?p : Presence ) : Presence {
		if( stream.status != StreamStatus.open ) return null;
		if( p == presence ) return null;
		presence = if( p == null ) new Presence() else p;
		return stream.sendPacket( presence );
	}
	
	/**
		Change the presence.
	*/
	public inline function change( ?type : xmpp.PresenceType, ?show : String, ?status : String, ?priority : Int ) : xmpp.Presence {
		return set( new Presence( type, show, status, priority ) );
	}
	
}
