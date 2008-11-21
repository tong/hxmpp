package jabber.muc;


/**
TODO move into jabber.client.MUC
*/
class Occupant {
	
	//public var nick(getNick,setNick) : String;
	public var nick : String;
	public var jid : String;
	public var presence : xmpp.Presence;
	public var role : xmpp.muc.Role;
	public var affiliation : xmpp.muc.Affiliation;
	
	
	public function new() {}
	
	/*
	function getNick() { return nick; }
	function setNick( n : String ) {
		return nick = n;
	}
	*/
	
	#if JABBER_DEBUG
	public function toString() : String {
		return "MUCOccupant(nick=>"+nick+",role=>"+role+",prsnc_show=>"+presence.show+")";
	}
	#end
	
}
