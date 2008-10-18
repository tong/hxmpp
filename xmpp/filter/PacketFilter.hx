package xmpp.filter;


typedef PacketFilter = {
	
	/**
		Returns true if the given packet passes through this filter.
	*/
	function accept( packet : xmpp.Packet ) : Bool;
	
}
