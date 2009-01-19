
import jabber.component.Stream;


/**
	neko.
*/
class JabberComponentDemo {
	
	static var cnx : jabber.SocketConnection;
	static var stream : Stream;
	
	static function main() {
		
		jabber.util.XMPPDebug.redirectTraces();
		
		cnx = new jabber.SocketConnection( "127.0.0.1", Stream.defaultPort );
		stream = new Stream( "disktree", "", "1234", cnx );
		stream.onOpen = function(s) {
			trace("JABBER STREAM opened...");
		};
		stream.onClose = function(s) { trace( "Stream to: "+s.jid.domain+"closed." ); } ;
		stream.onConnect = function(success) {
			trace( "Stream opened. Have fun!" );
			var keepAlive = new net.util.KeepAlive( cnx.socket ).start();
			//..
		}
		stream.open();
	}
		
}
