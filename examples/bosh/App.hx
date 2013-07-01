
import jabber.client.Stream;
import jabber.client.Authentication;

class App {

	static function main() {
		var creds = XMPPClient.getAccountFromFile( 'a' );
		var jid = creds.user+'@'+creds.host;
		var cnx = new jabber.BOSHConnection( creds.host, creds.http );
		var stream = new Stream( cnx );
		stream.onOpen = function() {
			var auth = new Authentication( stream, [
				new jabber.sasl.MD5Mechanism()
			] );
			auth.onFail = function(e) {
				trace( "Authentication failed ("+stream.jid+")" );
				stream.close( true );
			}
			auth.onSuccess = function() {
				trace( "Authenticated as "+stream.jid );
				stream.sendPresence();
			}
			auth.start( creds.password, 'hxmpp-bosh' );
		}
		stream.onClose = function(?e) {
			if( e == null )
				trace( 'XMPP stream closed' );
			else
				trace( 'XMPP stream error : $e' );
			cnx.disconnect();
		}
		stream.open( jid );
	}

}
