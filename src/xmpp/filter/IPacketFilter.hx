package xmpp.filter;


interface IPacketFilter {
	
	/**
		Returns true if the given packet passes through this filter.
	*/
	function accept( packet : xmpp.Packet ) : Bool;
}