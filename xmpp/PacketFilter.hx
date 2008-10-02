package xmpp;


typedef PacketFilter = {
	
	/**
		Returns boolean if the given packet passes through this filter.
	*/
	function accept( packet : xmpp.Packet ) : Bool;
	
}
