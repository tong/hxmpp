package jabber.stream;


/**
	Modifies xmpp.Packets before sending.
*/
typedef TPacketInterceptor = {
	
	/**
		Intercepts outgoing xmpp packet.
	*/
	function interceptPacket( p : xmpp.Packet ) : xmpp.Packet;
	
}
