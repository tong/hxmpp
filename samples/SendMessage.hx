
import jabber.client.Stream;

class SendMessage {
	
	static var stream : Stream;
	
	static function main() {
		stream = new Stream( new jabber.JID( "hxmpp@disktree" ), new jabber.SocketConnection( "127.0.0.1", Stream.defaultPort ) );
		stream.onOpen = function() {
			var auth = new jabber.client.NonSASLAuthentication( stream );
			auth.onSuccess = handleLogin;
			auth.onFail = function(?e) {
				trace( "Login failed "+e.name );
				return;
			};
			auth.authenticate( "test", "HXMPP" );
		};
		trace( "Initializing XMPP stream ..." );
		stream.open();
	}
	
	static function handleLogin() {
		stream.sendMessage( "hxmpp_reciever@disktree/HXMPP", "Test message." );
	}
	
}
