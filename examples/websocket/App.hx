
class App {
	
	static function main() {

		var user = "hxmpp";
		var host = "jabber.disktree.net";
		var ip = "localhost";
		var password = "test";
		var port = 5222;
		
		trace( 'Connecting to $ip:$port' );
		
		var cnx = new jabber.SocketConnection( ip, port );
		
		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function(){
			trace( "XMPP stream opened" );
			var auth = new jabber.client.Authentication( stream, [new jabber.sasl.MD5Mechanism()] );
			auth.onSuccess = function() {
				trace("logged in");
				stream.sendPresence();
			}
			auth.start( password, "hxmpp-websocket" );
		}
		stream.onClose = function(?e){
			trace( "XMPP stream closed" );
			if( e != null ) trace(e);
		};
		stream.open( '$user@$host' );
	}
	
}
