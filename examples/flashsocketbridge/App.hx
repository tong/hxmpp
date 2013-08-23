
import jabber.SocketConnection;

/**
	Connect to a XMPP server from javascript using a flash socketbridge.
*/
@:require(js)
@:require(jabber_flashsocketbridge)
class App {
	
	static function main() {

		trace( 'Initializing flashsocketbridge ...' );

		SocketConnection.init( 'flashsocketbridge', function(e:String) {
			
			if( e != null ) {
				trace( e );
				return;
			}
			trace( 'Flashsocketbridge ready' );

			var creds = XMPPClient.defaultAccountCredentials; //getAccountCredentials();
			var jid = creds.user+'@'+creds.host;
			var cnx = new SocketConnection( creds.host );
			var stream = new jabber.client.Stream( cnx );
			stream.onClose = function(?e){
				trace( 'XMPP stream closed : '+e );
			}
			stream.onOpen = function(){
				trace( 'XMPP stream opened' );
				var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
				auth.onSuccess = function() {
					trace( 'Authenticated [$jid]' );
					stream.sendPresence();
				}
				auth.start( creds.password, "hxmpp" );
			}
			trace(">>>>>>>>>> "+jid );
			stream.open( jid );
		}, 200 );
	}
}
