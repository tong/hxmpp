
import jabber.component.Stream;

class ComponentDemo {
	
	static var cnx : jabber.SocketConnection;
	static var stream : Stream;
	
	static function main() {
		
		trace( "HXMPP server component example" );
		
		var identity = { category : "conference", name : "MYSERVICE", type : "text" };
		cnx = new jabber.SocketConnection( "127.0.0.1", Stream.defaultPort );
		stream = new Stream( "disktree", "norc", "1234", cnx, [identity] );
		stream.onOpen = function() {
			trace( "XMPP stream opened.", "info" );
		};
		//stream.onError = function(?m) { trace( "Stream error, "+m ); } ;
		stream.onClose = function(?e) { trace( "Stream closed." ); } ;
		stream.onConnect = function() {
			trace( "Component connected. Have fun!", "info" );
		}
		trace( "Connecting to server ("+stream.host+") ..." );
		stream.open();
	}
	
}
