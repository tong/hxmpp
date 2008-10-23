
import jabber.component.Stream;


class JabberComponentDemo {
	
	static function main() {
		
		jabber.util.XMPPDebug.redirectTraces();
		
		var stream = new Stream( "norc", "1234", new jabber.SocketConnection( "127.0.0.1", Stream.defaultPort ) );
		stream.onOpen = function(s) {
			trace("JABBER STREAM opened...");
		};
		stream.onClose = function(s) { trace( "Stream to: "+s.jid.domain+"closed." ); } ;
		stream.onAuthenticated = function(s) {
			trace( "Stream opened. Have fun!" );
		}
		stream.open();
	}
		
}
