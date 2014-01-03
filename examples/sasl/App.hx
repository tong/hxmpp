
/**
	Example/Test of different SASL mechanisms for account authentication
*/
class App {
	
	static function main() {
		
		var creds = XMPPClient.readArguments();
		
		var mechs : Array<jabber.sasl.Mechanism> = [
			new jabber.sasl.MD5Mechanism(),
			new jabber.sasl.PlainMechanism(),
			//new jabber.sasl.LOGINMechanism(),
		];

		var cnx = new jabber.SocketConnection( creds.ip, creds.port, false );
		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function() {
			trace( "XMPP stream opened" );
			var auth = new jabber.client.Authentication( stream, mechs );
			auth.onSuccess = function() {
				trace( "Authenticated as: "+stream.jid.toString() );
				stream.sendPresence();
			}
			auth.onFail = function(e) {
				trace( "Authentication failed: "+e );
			}
			auth.start( creds.password, 'hxmpp' );
		}
		stream.onClose = function(?e) {
			if( e != null ) trace( e ) else trace( "XMPP stream closed" );
		}
		stream.open( creds.jid );
	}
	
}
