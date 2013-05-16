
import jabber.client.Stream;
import jabber.client.Authentication;

class App {

	static var JID = "hxmpp@jabber.org";
	static var PASSWORD = "mypassword";
	static var IP = null; //localhost";
	static var RESOURCE = "abz-hxmpp";

	static var stream : Stream;

	static function main() {
		
		var jid = new jabber.JID( JID );
		if( IP == null )
			IP = jid.domain;
		
		var cnx = new jabber.SocketConnection( IP, 5222, false );
		
		stream = new Stream( cnx );
		stream.onOpen = function() {
			var auth = new Authentication( stream, [
				new jabber.sasl.MD5Mechanism()
			] );
			auth.onFail = function(e) {
				trace( "Authentication failed ("+stream.jid+")", "warn" );
				stream.close( true );
			}
			auth.onSuccess = function() {
				trace( "Authenticated as "+stream.jid );
				stream.sendPresence();
			}
			auth.start( PASSWORD, RESOURCE );
		}
		stream.onClose = function(?e) {
			if( e == null )
				trace( 'XMPP stream closed', 'warn' );
			else
				trace( 'XMPP stream error : $e', 'error' );
			cnx.disconnect();
		}

		stream.open( jid );
	}

}
