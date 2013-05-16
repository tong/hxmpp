
/**
	Julia tries to capture romeos 'attention'.
	Will she be successful ? muahaha
*/
class AppJulia extends XMPPClient {
	
	static var entity = 'romeo@disktree/HXMPP';
	static var requestedAttention = false;
	
	override function onLogin() {
		super.onLogin();
		new jabber.MessageListener( stream, onMessage );
		new jabber.PresenceListener( stream, onPresence );
		stream.sendPresence();
	}
	
	function onPresence( p : xmpp.Presence ) {
		if( !requestedAttention && p.from == entity ) {
			jabber.Attention.capture( stream, entity, 'Hey, give me some attention!' );
			requestedAttention = true;
		}
	}
	
	function onMessage( m : xmpp.Message ) {
		if( xmpp.Delayed.fromPacket( m ) != null )
			return;
		trace( m.from+': '+m.body );
	}
	
	static function main() {
		new AppJulia( XMPPClient.getAccountFromFile(2) ).login();
	}

}
