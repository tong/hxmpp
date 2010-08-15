package jabber.jingle;

interface SessionResponder {
	function handleRequest( iq : xmpp.IQ ) : Bool;
}
