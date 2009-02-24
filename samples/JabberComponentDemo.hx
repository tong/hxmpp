
import jabber.component.Stream;


/**
*/
class JabberComponentDemo {
	
	static var cnx : jabber.SocketConnection;
	static var stream : Stream;
	
	static function main() {
		
		#if XMPP_DEBUG
		jabber.XMPPDebug.redirectTraces();
		#end
		
		cnx = new jabber.SocketConnection( "127.0.0.1", Stream.defaultPort );
		stream = new Stream( "disktree", "norc", "1234", cnx );
		stream.onOpen = function(s) {
			trace( "XMPP stream opened.", "info" );
		};
		stream.onError = function(s,?m) { trace( "Stream error, "+m ); } ;
		stream.onClose = function(s) { trace( "Stream closed." ); } ;
		stream.onConnect = function(success:Bool) {
			if( success ) {
				trace( "Stream opened. Have fun!", "info" );
				// keep the stream alive
				#if !php
				var keepAlive = new net.util.KeepAlive( cnx.socket ).start();
				#end
				//..
			} else {
				trace( "Authentication failed" );
			}
		}
		stream.open();
	}
	
}
