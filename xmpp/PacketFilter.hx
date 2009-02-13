package xmpp;


typedef PacketFilter = {
	
	/**
		Returns Bool if the given XMPP packet passes through this filter.
	*/
	function accept( packet : xmpp.Packet ) : Bool;
	
}
