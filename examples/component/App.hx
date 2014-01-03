
import jabber.component.Stream;

/**
	HXMPP server component example
*/
class App {
	
	static var SERVER = "jabber.disktree.net";
	static var COMPONENT = "thecomp";
	static var SECRET = "1234";
	static var IP = "localhost";
	
	static function main() {
		var identity = { category : "conference", name : COMPONENT, type : "text" };
		var cnx = new jabber.SocketConnection( IP, 5275 );
		var stream = new Stream( cnx );
		stream.onOpen = function() {
			trace( "XMPP stream opened" );
		}
		stream.onClose = function(?e) {
			if( e == null ) trace( "XMPP stream closed" );
			else {
				trace(e);
				stream.close(true);
			}
		}
		stream.onReady = function() {
			trace( "Server component connected." );
		}
		trace( "Connecting to jabber server" );
		stream.open( SERVER, COMPONENT, SECRET, [identity] );
	}
	
}
