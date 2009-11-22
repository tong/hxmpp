
import jabber.client.Stream;
#if neko
import neko.Sys;
#elseif php
import php.Sys;
#elseif
import cpp.Sys;
#end

class SendMessage {
	
	static var stream : Stream;
	
	static function handleLogin() {
		trace( "Sending message ..." );
		stream.sendMessage( "reciever@domain.net/Resource", "Test message" );
		trace( "Message sent." );
		Sys.exit(0);
	}
	
	static function main() {
		stream = new Stream( new jabber.JID( "hxmpp@domain.net" ), new jabber.SocketConnection( "domain.net", Stream.defaultPort ) );
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
	
}
