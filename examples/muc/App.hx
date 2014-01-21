
import jabber.client.MUChat;

class App extends XMPPClient {
	
	var muc : MUChat;

	override function onLogin() {
	
		super.onLogin();

		stream.sendPresence();
		
		muc = new MUChat( stream, 'conference.jabber.disktree.net', 'haxe' );
		muc.onJoin = onMUChatJoin;
		muc.onLeave = onMUChatLeave;
		muc.onUnlock = onMUChatUnlock;
		muc.onMessage = onMUChatMessage;
		muc.onPresence = onMUChatPresence;
		muc.onSubject = onMUChatSubject;
		muc.onError = onMUChatError;
		muc.join( "Rambo" );
	}

	function onMUChatJoin() {
		trace( 'Joined chat room' );
	}

	function onMUChatLeave() {
		trace( 'Left chat room' );
	}

	function onMUChatUnlock() {
		trace( 'Unlocked chat room' );
	}

	function onMUChatMessage( o : MUChatOccupant, m : xmpp.Message ) {
		trace( m);
	}

	function onMUChatPresence( o : MUChatOccupant ) {
		trace(o);
	}

	function onMUChatSubject( o : String, s : String ) {
		trace( '$o changed subject to $s' );
	}

	function onMUChatError(e) {
		trace(e);
	}
	
	static function main() {
		var creds = XMPPClient.readArguments();
		new App( creds.jid, creds.password, creds.ip, creds.http ).login();
	}
	
}
