package jabber.stream;

/**
*/
class PacketCollector {
	
	public var filters(getFilters,setFilters) : Array<xmpp.PacketFilter>;
	public var handlers : Array<xmpp.Packet->Void>;
	public var permanent : Bool;
	public var block : Bool;
	public var timeout(default,setTimeout) : PacketTimeout;
	public var packet(default,null) : xmpp.Packet;
	
	var _f_id : Array<xmpp.PacketFilter>;
	var _f : Array<xmpp.PacketFilter>;
	
	public function new( filters : Array<xmpp.PacketFilter>, handler : Dynamic->Void,
						 ?permanent : Bool = false, ?timeout : PacketTimeout, ?block : Bool = false ) {
		
		handlers = new Array();
		_f_id = new Array();
		_f = new Array();
		setFilters( filters );
		if( handler != null )
			handlers.push( handler );
		this.permanent = permanent;
		this.block = block;
		this.setTimeout( timeout );
	}
	
	function getFilters() : Array<xmpp.PacketFilter> {
		return _f_id.concat( _f );
	}
	
	function setFilters( _f : Array<xmpp.PacketFilter> ): Array<xmpp.PacketFilter> {
		for( f in _f ) {
			if( Std.is( f, xmpp.filter.PacketIDFilter ) ) _f_id.push( f );
			else _f.push( f );
		}
		return _f_id.concat( _f );
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
		Returns true if the xmpp packet passes through all filters.
	*/
	public function accept( p : xmpp.Packet ) : Bool {
		for( f in getFilters() ) {
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
