
import XMPPClient;

/**
	Example/Test of SASL mechanisms for authentication
*/
class App {
	
	static function main() {
		
		var creds : AccountCredentials = XMPPClient.getAccountFromFile();
		
		#if (js&&!nodejs)
		var cnx = new jabber.BOSHConnection( creds.host, creds.http );
		#else
		var cnx = new jabber.SocketConnection( creds.ip, creds.port, false );
		#end

		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function() {
			
			trace( "XMPP stream opened" );
			
			var mechs : Array<jabber.sasl.Mechanism> = [
				new jabber.sasl.MD5Mechanism(),
				new jabber.sasl.PlainMechanism()
			];
			var auth = new jabber.client.Authentication( stream, mechs );
			auth.onSuccess = function() {
				trace( "Authenticated as: "+stream.jid.toString() );
				stream.sendPresence();
			}
			auth.start( "test", "thisistheresource" );
		}
		stream.onClose = function(?e) {
			trace( "XMPP stream closed" );
			if( e != null ) trace( e );
		}
		stream.open( new jabber.JID( creds.user+"@"+creds.host ) );
	}
	
}
