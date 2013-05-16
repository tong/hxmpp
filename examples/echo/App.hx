
import jabber.client.Stream;
import jabber.client.Authentication;

/**
	Echo client
*/
class App {

	//static var JID = "tong@om";
	//static var PASSWORD = "test";
	//static var IP = "localhost";
	
	/*
	static var JID = "hxmpp@jabber.org";
	static var PASSWORD = "mypassword";
	static var IP = null;
	static var RESOURCE = "abz-hxmpp";
	*/
	static var JID = "hxmpp@jabber.spektral.at";
	static var PASSWORD = "test77";
	static var IP = null;
	static var RESOURCE = "abz-hxmpp";

	static var stream : Stream;

	static function onMessage( m : xmpp.Message ) {

		if( xmpp.Delayed.fromPacket( m ) != null )
			return; // avoid processing of offline sent messages

		var jid = new jabber.JID( m.from ); // get jid of 'from' field
		
		trace( "Recieved message from "+jid.bare+" at resource: "+jid.resource );
		
		// --- send response message
		stream.sendPacket( new xmpp.Message( m.from, "Hello darling aka "+jid.node ) );
	}

	static function main() {
		
		var jid = new jabber.JID( JID );
		if( IP == null )
			IP = jid.domain;
		
		//var cnx = new jabber.SecureSocketConnection( IP, 5222, false );
		var cnx = new jabber.SocketConnection( IP, 5222, false );
		
		stream = new Stream( cnx );
		stream.onOpen = function() {
			var auth = new Authentication( stream, [
				//new jabber.sasl.LOGINMechanism()
				//new jabber.sasl.MD5Mechanism()
				new jabber.sasl.PlainMechanism()
			] );
			auth.onFail = function(e) {
				trace( "Authentication failed ("+stream.jid+")", "warn" );
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
				trace( 'XMPP stream closed', 'warn' );
			else
				trace( 'XMPP stream error : $e', 'error' );
			cnx.disconnect();
		}

		stream.open( jid );
	}

}
