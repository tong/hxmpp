
import jabber.SocketConnection;

/**
	Connect to a XMPP server from javascript using a flash socketbridge.
*/
@:require(js)
class App {
	
	static function main() {
		var creds = XMPPClient.defaultAccountCredentials;
		trace( 'Initializing flashsocketbridge' );
		jabber.SocketConnection.init( 'flashsocketbridge', function(e:String) {
			if( e != null ) {
				trace( e );
				return;
			}
			trace( 'Flashsocketbridge ready' );
			var cnx = new SocketConnection( creds.ip );
			var stream = new jabber.client.Stream( cnx );
			stream.onClose = function(?e){
				trace( 'XMPP stream closed : '+e );
			}
			stream.onOpen = function(){
				trace( 'XMPP stream opened' );
				var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
				auth.onSuccess = function() {
					stream.sendPresence();
				}
				auth.start( creds.password, "hxmpp" );
			}
			stream.open( creds.jid );
		}, 200 );
	}
}
