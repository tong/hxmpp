
/**
	Send a HTML formatted chat message.
*/
class App extends XMPPClient {
	
	override function onLogin() {
		super.onLogin();
		stream.sendPresence();
	}

	override function onPresence( p : xmpp.Presence ) {
		var m = new xmpp.Message( p.from, "This is a test" );
		xmpp.XHTML.attach( m, '<a href="http://hxmpp.disktree.net/"><strong>DISKTREE.NET</strong></a>' );
		stream.sendPacket( m );
	}
	
	static function main() {
		var creds = XMPPClient.readArguments();
		new App( creds.jid, creds.password, creds.ip, creds.http ).login();
	}
	
}
