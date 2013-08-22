
import jabber.component.Stream;

/**
	HXMPP server component example
*/
class App {
	
	static var SERVER = "disktree";
	static var COMPONENT = "mycomp";
	static var SECRET = "1234";
	static var IP = "127.0.0.1";
	
	static function main() {
		
		trace( "HXMPP server component example" );
		
		var identity = { category : "conference", name : COMPONENT, type : "text" };
		var cnx = new jabber.SocketConnection( IP, 5275 );
		var stream = new Stream( cnx );
		stream.onOpen = function() {
			trace( "XMPP stream opened" );
		}
		stream.onClose = function(?e) {
			if( e == null ) trace( "XMPP stream closed" );
			else {
				trace( "XMPP stream error: "+e );
				stream.cnx.disconnect();
			}
		}
		stream.onReady = function() {
			trace( "Component connected. Have fun!" );
		}
		trace( "Connecting to server  ..." );
		stream.open( SERVER, COMPONENT, SECRET, [identity] );
	}
	
}
