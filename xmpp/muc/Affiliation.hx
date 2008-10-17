package xmpp.muc;


/**
	Long-lived association or connection with a room.<br/>
	<a href="http://xmpp.org/extensions/xep-0045.html#connections">Roles and Affiliations</a>
*/
enum Affiliation {
	none;
	owner;
	admin;
	member;
	outcast;
}
