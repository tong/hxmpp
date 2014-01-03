
import jabber.Attention;
import jabber.JID;

using jabber.JIDUtil;

/**
	Example usage of: http://xmpp.org/extensions/xep-0224.html
*/
class App extends XMPPClient {
	
	override function onLogin() {
		super.onLogin();
		stream.sendPresence();
	}
	
	override function onPresence( p : xmpp.Presence ) {
		Attention.capture( stream, p.from, 'Can i have your attention please' );
	}
	
	override function onMessage( m : xmpp.Message ) {
		if( xmpp.Delayed.is( m ) )
			return;
		if( Attention.isRequest(m) )
			trace( 'ATTENTION! '+m.body );
	}
	
	static function main() {
		var creds = XMPPClient.readArguments();
		var client = new App( creds.jid, creds.password, creds.ip, creds.http );
		client.login();
	}

}
