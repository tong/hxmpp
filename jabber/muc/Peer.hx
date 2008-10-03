package jabber.muc;


typedef Peer = {
	
	var nickname : String;
	
	var presence : xmpp.Presence;
	
	var role : Role;
	
	var affiliation : Affiliation;
	
	//var room : RoomInfo;
	
}
