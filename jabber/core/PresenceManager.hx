package jabber.core;

import jabber.StreamStatus;


/**
	Wrapper for presence handling.
*/
class PresenceManager {
	
	public var type(getType,setType) : xmpp.PresenceType;
	public var show(getShow,setShow) : String;
	public var status(getStatus,setShow) : String;
	public var priority(getPriority,setPriority) : Int;
	
	var stream : jabber.core.StreamBase;
	var p : xmpp.Presence;
	
	
	public function new( s : jabber.core.StreamBase ) {
		stream = s;
		p = new xmpp.Presence();
	}
	
	
	function getType() : xmpp.PresenceType { return p.type; }
	function setType( v : xmpp.PresenceType ) : xmpp.PresenceType {
		if( v == p.type ) return v;
		p.type = v;
		if( stream.status == StreamStatus.open ) stream.sendPacket( p );
		return v;
	}
	function getShow() : String { return p.show; }
	function setShow( v : String ) : String {
		if( v == p.show ) return v;
		p.show = v;
		if( stream.status == StreamStatus.open ) stream.sendPacket( p );
		return p.show;
	}
	function getStatus() : String { return p.status; }
	function setStatus( v : String ) : String {
		if( v == p.status ) return v;
		p.status = v;
		if( stream.status == StreamStatus.open ) stream.sendPacket( p );
		return p.status;
	}
	function getPriority() : Int { return p.priority; }
	function setPriority( v : Int ) : Int {
		if( v == p.priority ) return v;
		p.priority = v;
		if( stream.status == StreamStatus.open ) stream.sendPacket( p );
		return p.priority;
	}
	
	
	/**
		Change the presence by passing in a xmpp.Presence packet.
	*/
	public function set( ?p : xmpp.Presence ) : xmpp.Presence {
		if( p == null || p == this.p ) return null;
		return stream.sendPacket( this.p = p );
	}
	
	/**
		Change the presence by changing presence values.
	*/
	public function change( ?type : xmpp.PresenceType, ?show : String, ?status : String, ?priority : Int ) : xmpp.Presence {
		p = new xmpp.Presence();
		if( type != p.type ) p.type = type;
		if( show != p.show ) p.show = show;
		if( status != p.status ) p.status = status;
		if( priority != p.priority ) p.priority = priority;
		return stream.sendPacket( p );
	}
	
}
