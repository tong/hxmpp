package xmpp.filter;


/**
	Accepts every packet.
*/
class PacketAllFilter {
	public function new() {}
	public function accept( p : xmpp.Packet ) : Bool { return true; }
}
