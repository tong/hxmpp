
import jabber.SocketConnection;

/**
	Connect to a XMPP server from javascript using a flash socketbridge.
*/
class App {
	
	static function main() {

		trace( 'Initializing flashsocketbridge ...' );
		
		SocketConnection.init( 'flashsocketbridge', function(e:String) {
			
			if( e != null ) {
				trace( e );
				return;
			}

			trace( 'flashsocketbridge ready' );
			
			var cnx = new SocketConnection( "localhost", 5222 );
			var stream = new jabber.client.Stream( cnx );
			stream.onOpen = function(){
				trace( 'XMPP stream opened' );
				var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
				auth.onSuccess = function() {
					trace( 'Authenticated ['+stream.jid.toString()+']' );
					stream.sendPresence();
				}
				auth.start( "test", "HXMPP" );
			}
			stream.open( "romeo@jabber.disktree.net" );
		}, 200 );
		
	}
}
