package jabber.muc;


/**
	Long-lived association or connection with a room.
*/
enum Affiliation {
	none;
	owner;
	admin;
	member;
	outcast;
}
