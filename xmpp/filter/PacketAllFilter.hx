package xmpp.filter;


/**
	Accepts every packet.
*/
class PacketAllFilter {
	public function new() {}
	public function accept( packet : xmpp.Packet ) : Bool { return true; }
}
