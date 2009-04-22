
import jabber.component.Stream;

class JabberComponentDemo {
	
	//static var HOST = ""127.0.0.1"";
	
	static var cnx : jabber.SocketConnection;
	static var stream : Stream;
	
	static function main() {
		
		#if XMPP_DEBUG
		jabber.XMPPDebug.redirectTraces();
		#end
		
		trace( "HXMPP Server component example" );
		
		cnx = new jabber.SocketConnection( "127.0.0.1", Stream.defaultPort );
		stream = new Stream( "disktree", "norc", "1234", cnx );
		stream.onOpen = function() {
			trace( "XMPP stream opened.", "info" );
		};
		stream.onError = function(?m) { trace( "Stream error, "+m ); } ;
		stream.onClose = function() { trace( "Stream closed." ); } ;
		stream.onConnect = function() {
			trace( "Component connected. Have fun!", "info" );
		}
		trace( "Connecting to server ..." );
		stream.open();
	}
	
}
