package jabber;

/**
	Utility (shortcut) to listen/report incoming message packets.
*/
class MessageListener extends jabber.stream.TopLevelPacketListener<xmpp.Message> {
	public function new( stream : Stream, handler : xmpp.Message->Void, ?listen : Bool = true ) {
		super( stream, handler, xmpp.PacketType.message, listen );
	}
}
