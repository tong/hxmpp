package jabber.core;

import xmpp.Packet;


/**
	Modifies outgoing xmpp.Packets before sending.
*/
interface IPacketInterceptor {
	
	/**
		Intercepts xmpp packet.
	*/
	function intercept( packet : xmpp.Packet ) : xmpp.Packet;
}
