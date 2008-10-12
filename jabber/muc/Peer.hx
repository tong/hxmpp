package jabber.muc;


/*TODO
class Occupant extends Peer {
	
	public var nick : String;
	public var jid : String;
	public var presence : xmpp.Presence;
	public var role : Role;
	public var affiliation : Affiliation;
	
	public function new() {
	}
	
}
*/


typedef Peer = {
	
	var nickname : String;
	
	var presence : xmpp.Presence;
	
	var role : Role;
	
	var affiliation : Affiliation;
	
	//var room : RoomInfo;
	
}
