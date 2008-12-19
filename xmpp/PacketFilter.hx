package xmpp;


typedef PacketFilter = {
	
	/**
		Returns true if the given xmpp packet passes through this filter.
	*/
	function accept( packet : xmpp.Packet ) : Bool;
	
}
