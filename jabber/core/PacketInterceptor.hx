package jabber.core;


/**
	Modifies xmpp.Packets before sending.
*/
//interface IPacketInterceptor {
typedef PacketInterceptor = {
	/**
		Intercepts xmpp packet.
	*/
	function interceptPacket( p : xmpp.Packet ) : xmpp.Packet;
	
}
