
import jabber.component.Stream;


class JabberComponentDemo {
	
	static var connection : jabber.SocketConnection;
	static var stream : Stream;
	
	static function main() {
		
		jabber.util.XMPPDebug.redirectTraces();
		
		connection = new jabber.SocketConnection( "127.0.0.1", Stream.defaultPort );
		stream = new Stream( "norc", "1234", connection );
		stream.onOpen = function(s) {
			trace("JABBER STREAM opened...");
		};
		stream.onClose = function(s) { trace( "Stream to: "+s.jid.domain+"closed." ); } ;
		stream.onAuthenticated = function(s) {
			var keepAlive = new net.util.KeepAlive( connection.socket ).start();
			trace( "Stream opened. Have fun!" );
		}
		stream.open();
	}
		
}
