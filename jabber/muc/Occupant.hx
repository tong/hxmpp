package jabber.muc;


class Occupant {
	
	public var nick : String;
	public var jid : String;
	public var presence : xmpp.Presence;
	public var role : Role;
	public var affiliation : Affiliation;
	
	public function new() {
	}
	
}
