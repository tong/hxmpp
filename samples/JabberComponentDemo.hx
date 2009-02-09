
import jabber.component.Stream;


/**
	neko.
*/
class JabberComponentDemo {
	
	static var cnx : jabber.SocketConnection;
	static var stream : Stream;
	
	static function main() {
		
		jabber.XMPPDebug.redirectTraces();
		
		cnx = new jabber.SocketConnection( "127.0.0.1", Stream.defaultPort );
		stream = new Stream( "disktree", "norc", "1234", cnx );
		stream.onOpen = function(s) {
			trace("JABBER STREAM opened...");
		};
		stream.onError = function(s,?m) { trace( "Stream error, "+m ); } ;
		stream.onClose = function(s) { trace( "Stream closed." ); } ;
		stream.onConnect = function(success:Bool) {
			
			if( success ) {
				trace( "Stream opened. Have fun!" );
				// keep the stream alive
				var keepAlive = new net.util.KeepAlive( cnx.socket ).start();
			}
		}
		stream.open();
	}
	
}
