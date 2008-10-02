package jabber.core;


/**
	Modifies xmpp.Packets before sending.
*/
interface IPacketInterceptor {
	
	/**
		Intercepts xmpp packet.
	*/
	function interceptPacket( packet : xmpp.Packet ) : xmpp.Packet;
	
}
