package jabber.roster;

import xmpp.Roster;


class Entry {
	
	public var jid : String;
	public var subscription : Subscription;
	public var name : String;
	public var presence : xmpp.Presence; // TODO var presence : Hash<xmpp.Presence>;
	public var askType : AskType;
	public var groups : List<String>;
	public var resource : String; // TODO var resource : List<String>;
	
	public function new() {}
	
}

/*
typedef Entry = {
	var jid : String;
	var subscription : Subscription;
	var name : String;
	var presence : xmpp.Presence; // TODO var presence : Hash<xmpp.Presence>;
	var askType : AskType;
	var groups : List<String>;
	var resource : String; // TODO var resource : List<String>;
}
*/
