package jabber;

/**
	Utility (shortcut) to listen/report incoming presence packets.
*/
class PresenceListener extends jabber.stream.TopLevelPacketListener<xmpp.Presence> {
	public function new( stream : Stream, handler : xmpp.Presence->Void, ?listen : Bool = true ) {
		super( stream, handler, xmpp.PacketType.presence, listen );
	}
}
