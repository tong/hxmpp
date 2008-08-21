package jabber.roster;

import xmpp.iq.Roster;

/*
typedef RosterEntry = {
	var jid 			: String;
	var subscription 	: Subscription;
	var name 			: String;
	var presence 		: xmpp.Presence;//var presence : Hash<xmpp.Presence>;
	var askType 		: AskType;
	var groups 			: List<String>;
	var resource 		: String;//var resource : List<String>;
}
*/


class RosterEntry {
	
	public var jid : String;
	public var subscription : Subscription;
	public var name : String;
	public var presence : xmpp.Presence;//var presence : Hash<xmpp.Presence>;
	public var askType : AskType;
	public var groups : List<String>;
	public var resource : String;//var resource : List<String>;
	
	
	public function new() {
	}
	
}
