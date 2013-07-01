
import jabber.client.Stream;
import jabber.client.Authentication;

/**
	XMPP echo client
*/
class App {

	static var JID = "user@example.com";
	static var PASSWORD = "mypassword";
	static var IP = null;
	static var RESOURCE = "hxmpp";

	static var stream : Stream;

	static function onMessage( m : xmpp.Message ) {

		// avoid processing of offline sent messages
		if( xmpp.Delayed.fromPacket( m ) != null )
			return;

		// get occupant jid from 'from' field
		var jid = new jabber.JID( m.from );
		
		trace( "Recieved message from "+jid.bare+" at resource: "+jid.resource );
		
		// send response message
		stream.sendPacket( new xmpp.Message( m.from, "Hello darling aka "+jid.node ) );
	}

	static function main() {
		var jid = new jabber.JID( JID );
		if( IP == null )
			IP = jid.domain;
		var cnx = new jabber.SocketConnection( IP, 5222, false );
		stream = new Stream( cnx );
		stream.onOpen = function() {
			var auth = new Authentication( stream, [
				//new jabber.sasl.LOGINMechanism()
				//new jabber.sasl.MD5Mechanism()
				new jabber.sasl.PlainMechanism()
			] );
			auth.onFail = function(e) {
				trace( "Authentication failed ("+stream.jid+")" );
				stream.close( true );
			}
			auth.onSuccess = function() {
				trace( "Authenticated as "+stream.jid );
				new jabber.MessageListener( stream, onMessage ); // --- listen for messages
				stream.sendPresence(); // --- send initial presence 
			}
			auth.start( PASSWORD );
		}
		stream.onClose = function(?e) {
			if( e == null )
				trace( 'XMPP stream closed' );
			else
				trace( 'XMPP stream error : $e' );
			cnx.disconnect();
		}
		stream.open( jid.bare );
	}

}
