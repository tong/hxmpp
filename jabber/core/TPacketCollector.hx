package jabber.core;


/**
*/
typedef TPacketCollector = {
	
	/**
	*/
	var filters : Array<xmpp.PacketFilter>;
	//function addFilter( f : xmpp.PacketFilter ) : Bool;
	//function removeFilter( f : xmpp.PacketFilter ) : Bool;
	//function clearFilters() : Void;
	
	
	/**
		Callbacks to which collected packets get delivered to.
	*/
	var handlers : Array<xmpp.Packet->Void>;
	
	/**
		Indicates if the the collector should get removed from the streams after collecting.
	*/
	var permanent : Bool;
	
	/**
		Blocks remaining collectors.
		Default value should be false.
	*/
	var block : Bool;
	
	/**
	*/
	var timeout(default,setTimeout) : PacketTimeout;

	/**
		Last collected packet.
		??????????????????????????????????????????????? needed
	*/
	var packet(default,null) : xmpp.Packet;
	
	/**
		Returns true if the given xmpp packet passes through all filters.
	*/
	function accept( p : xmpp.Packet ) : Bool;
	
	/**
		Delivers the xmpp packet to registerd handlers.
	*/
	function deliver( p : xmpp.Packet ) : Void;
	
}
