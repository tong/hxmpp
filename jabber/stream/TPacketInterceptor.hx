package jabber.stream;

/**
	Modifies XMPP packets and/or runs additional processes before sending them.
*/
typedef TPacketInterceptor = {
	
	/**
		Intercepts outgoing XMPP packet.
	*/
	function interceptPacket( p : xmpp.Packet ) : xmpp.Packet;
	
}
