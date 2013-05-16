
/**
	Sends a XHTML HTTP link to a buddy.
*/
class App extends XMPPClient {
	
	override function onLogin() {
		super.onLogin();
		stream.sendPresence();
		var m = new xmpp.Message( "julia@om", "LINK" );
		stream.sendPacket( xmpp.XHTML.attach( m, '<a href="http://disktree.net"><strong>DISKTREE.NET</strong></a>' ) );
	}
	
	static function main() {
		new App().login();
	}
	
}
