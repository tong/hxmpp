package xmpp.filter;


/**
	Accepts every packet.
*/
class PacketAllFilter implements IPacketFilter {
	public function new() {}
	public function accept( packet : xmpp.Packet ) : Bool { return true; }
}
