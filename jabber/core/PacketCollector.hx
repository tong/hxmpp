package jabber.core;

import xmpp.filter.PacketFilter;


/**
	Default/Basic IPacketCollector implementation.
*/
class PacketCollector implements IPacketCollector {
	
	public static var DEFAULT_TIMEOUT = 5;
	
	public var filters : Array<PacketFilter>;
	public var handlers : Array<xmpp.Packet->Void>;
	public var permanent : Bool;
	public var block : Bool;
	public var timeout(default,setTimeout) : PacketTimeout;
	
	
	/**
		Creates a new packet collector instance.
		filters
		handler
		?permanent 
	*/
	public function new( filters : Array<PacketFilter>, handler : Dynamic->Void,
						 ?permanent : Bool = false, ?timeout : PacketTimeout, ?block : Bool = false ) {
		
		handlers = new Array();
		
		this.filters = filters;
		if( handler != null ) handlers.push( handler );
		this.permanent = permanent;
		this.block = block;
		this.setTimeout( timeout );
	}
	
	
	function setTimeout( t : PacketTimeout ) : PacketTimeout {
		
		if( timeout != null ) timeout.stop();
		timeout = null;
		
		if( t == null ) return null;
		if( permanent ) return null;
			
		timeout = t;
		timeout.collector = this;
		return timeout;
	}
	
	
	/**
		Returns true if the xmpp packet passes through all filters.
	*/
	public function accept( p : xmpp.Packet ) : Bool {
		for( f in filters ) if( !f.accept( p ) ) return false;
		return true;
	}
	
	/**
		Delivers the given packet to all registerd packet handlers.
	*/
	public function deliver( p : xmpp.Packet ) {
		for( handle in handlers ) handle( p );
	}
	
}
