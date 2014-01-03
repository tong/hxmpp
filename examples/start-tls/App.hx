
class App {
	
	static function connect() {
		var creds = XMPPClient.readArguments();
		var cnx = new jabber.SocketConnection( creds.ip, 5222, true );
		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function() {
			trace( "XMPP stream opened" );
			trace( "Socket secured: "+stream.cnx.secure );
			var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
			auth.onSuccess = function() {
				stream.sendPresence();
				new jabber.client.VCardTemp( stream ).load();
			}
			auth.start( creds.password, "hxmpp" );
		}
		stream.onClose = function(?e) {
			trace( if( e != null ) e else "XMPP stream closed" );
		}
		stream.open( creds.jid );
	}
	
	static function main() {
		#if js
		js.Browser.window.onload = function(_) {
			connect();
		}
		#else
		connect();
		#end
	}
}
