
/**
	Send a HTML formatted chat message.
*/
class App extends XMPPClient {
	
	override function onLogin() {

		super.onLogin();
		stream.sendPresence();

		var m = new xmpp.Message( "julia@om", "LINK" );
		xmpp.XHTML.attach( m, '<a href="http://disktree.net"><strong>DISKTREE.NET</strong></a>' );
		stream.sendPacket( m );
	}
	
	static function main() {
		new App().login();
	}
	
}
