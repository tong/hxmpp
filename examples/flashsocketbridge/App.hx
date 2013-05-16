
import jabber.SocketConnection;

/**
	Connect to a XMPP server from javascript using a flash socketbridge.
*/
class Test {
	
	static function main() {
		
		var useTSL = false; // make sure to use the correct socketbridge.swf when using SSL encryption (socketbridge_tls.swf)
		
		SocketConnection.init( 'socketbridge', function(e:String) {
			
			if( e != null ) {
				trace( e, 'error' );
				return;
			}

			trace( 'socketbridge initialized', 'info' );
			
			var cnx = new SocketConnection( "127.0.0.1", 5222, useTSL );
			var stream = new jabber.client.Stream( cnx );
			stream.onOpen = function(){
				trace( 'XMPP stream opened', 'info' );
				var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
				auth.onSuccess = function() {
					trace( 'Authenticated ['+stream.jid.toString()+']', 'info' );
					stream.sendPresence();
				}
				auth.start( "test", "HXMPP" );
			}
			stream.open( new jabber.JID( "romeo@disktree" ) );
		}, 200 );
		
		
	}
}
