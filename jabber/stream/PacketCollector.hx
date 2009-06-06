package jabber.stream;

private class Filters {
	
	var f_id : Array<xmpp.PacketFilter>;
	var f : Array<xmpp.PacketFilter>;
	
	public function new() {
		f_id = new Array<xmpp.PacketFilter>();
		f = new Array<xmpp.PacketFilter>();
	}
	
	public function iterator() : Iterator<xmpp.PacketFilter> {
		return f_id.concat( f ).iterator();
	}
	
	public function push( _f : xmpp.PacketFilter ) {
		if( Std.is( _f, xmpp.filter.PacketIDFilter ) ) f_id.push( _f );
		else f.push( _f );
	}
	
	public function unshift( _f : xmpp.PacketFilter ) {
		if( Std.is( _f, xmpp.filter.PacketIDFilter ) ) f_id.unshift( _f );
		else f.unshift( _f );
	}
	
	public function remove( _f : xmpp.PacketFilter ) : Bool {
		if( f_id.remove( _f ) ) return true;
		if( f.remove( _f ) ) return true;
		return false;
	
	}
}

/**
*/
class PacketCollector {
	
	/** */
	public var filters(default,null) : Filters;
	/** Callbacks to which collected packets get delivered to. */
	public var handlers : Array<xmpp.Packet->Void>;
	/** Indicates if the the collector should get removed from the streams after collecting. */
	public var permanent : Bool;
	/** Block remaining collectors. */
	public var block : Bool;
	/** */
	public var timeout(default,setTimeout) : PacketTimeout;
	/** */
	public var packet(default,null) : xmpp.Packet; //TODO remove
	
	public function new( filters : Iterable<xmpp.PacketFilter>, handler : Dynamic->Void,
						 ?permanent : Bool = false, ?timeout : PacketTimeout, ?block : Bool = false ) {
		
		handlers = new Array();
		this.filters = new Filters();
		for( f in filters )
			this.filters.push( f );
		if( handler != null )
			handlers.push( handler );
		this.permanent = permanent;
		this.block = block;
		this.setTimeout( timeout );
	}

	function setTimeout( t : PacketTimeout ) : PacketTimeout {
		if( timeout != null ) timeout.stop();
		timeout = null;
		if( t == null ) return null;
		if( permanent ) return null;
		timeout.collector = this;
		return timeout = t;
	}
	
	/**
		Returns true if the XMPP packet passes through all filters.
	*/
	public function accept( p : xmpp.Packet ) : Bool {
		for( f in filters ) {
			if( !f.accept( p ) )
				return false;
		}
		packet = p;
		return true;
	}
	
	/**
		Delivers the given packet to all registerd packet handlers.
	*/
	public function deliver( p : xmpp.Packet ) {
		for( h in handlers ) h( p );
	}
	
}
