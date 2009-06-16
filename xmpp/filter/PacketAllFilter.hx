package xmpp.filter;

/**
	Accepts every XMPP packet.
*/
class PacketAllFilter {
	public function new() {}
	public function accept( p : xmpp.Packet ) : Bool {
		return true;
	}
}
