
import XMPPClient;

/**
	Example/Test of SASL mechanisms for authentication
*/
class App {
	
	static function main() {
		
		var creds : AccountCredentials = XMPPClient.getAccountCredentials();
		//trace( creds );

		var mechs : Array<jabber.sasl.Mechanism> = [
			new jabber.sasl.MD5Mechanism(),
			new jabber.sasl.PlainMechanism(),
			//new jabber.sasl.LOGINMechanism(),
		];

		#if js
		var cnx = new jabber.BOSHConnection( creds.host, creds.http, 1, 30, false );
		#else
		var cnx = new jabber.SocketConnection( creds.ip, creds.port, false );
		#end
		
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
			auth.start( creds.password, XMPPClient.getPlatformResource() );
		}
		stream.onClose = function(?e) {
			trace( "XMPP stream closed" );
			if( e != null ) trace( e );
		}
		stream.open( creds.user+"@"+creds.host );
	}
	
}
