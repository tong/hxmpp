
using jabber.JIDUtil;

/**
	Example usage of: http://xmpp.org/extensions/xep-0224.html

	Julia tries to capture romeos 'attention'.
*/
class AppJulia extends XMPPClient {
	
	static var entity = 'romeo@disktree.local';
	static var requestedAttention = false;
	
	override function onLogin() {

		super.onLogin();

		new jabber.MessageListener( stream, onMessage );
		new jabber.PresenceListener( stream, onPresence );

		stream.sendPresence();
	}
	
	function onPresence( p : xmpp.Presence ) {
		if( !requestedAttention && p.from.bare() == entity ) {
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
		new AppJulia( XMPPClient.getAccountCredentials("julia") ).login();
	}

}
