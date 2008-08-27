package jabber.roster;

import xmpp.IQRoster;


class Entry {
	
	//public var roster : T;
	
	public var jid : String;
	public var subscription : Subscription;
	public var name : String;
	public var presence : xmpp.Presence; // TODO var presence : Hash<xmpp.Presence>;
	public var askType : AskType;
	public var groups : List<String>;
	public var resource : String; // TODO var resource : List<String>;
	
	
	function new() {}

}
