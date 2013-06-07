
/**
	Example usage of: http://xmpp.org/extensions/xep-0224.html
	Listens/Answers 'attention' requests
*/
class AppRomeo extends XMPPClient {
	
	override function onLogin() {
		super.onLogin();
		new jabber.AttentionListener( stream, onAttentionRequest );
		stream.sendPresence();
	}
	
	function onAttentionRequest( m : xmpp.Message ) {
		if( xmpp.Delayed.fromPacket( m ) != null )
			return;
		trace( m.from+" wants your attention", "info" );
		stream.sendMessage( m.from, 'You have my full attention' );
	}
	
	static function main() {
		new AppRomeo().login();
	}

}
