
class App {
	
	static function main() {
	
		var host = "localhost";
		var port = 7799;
		
		trace( 'Connecting websocket [$host:$port]' );
		
		var cnx = new jabber.SocketConnection( host, port );
		
		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function(){
			trace("XMPP stream opened");
			var auth = new jabber.client.Authentication( stream, [new jabber.sasl.MD5Mechanism()] );
			auth.onSuccess = function() {
				trace("logged in");
				stream.sendPresence();
			}
			auth.start( "test", "HXMPP-websocket" );
		}
		stream.onClose = function(?e){
			trace( "XMPP stream closed", "info" );
			if( e != null ) trace( e, "error" );
		};
		stream.open( new jabber.JID( "romeo@om" ) );
	}
	
}
