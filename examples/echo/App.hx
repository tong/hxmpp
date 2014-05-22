
import jabber.JID;
import jabber.client.Stream;
import jabber.client.Authentication;

/**
	Simple xmpp echo client
*/
class App {

	static var USER = 'romeo';
	static var SERVER = 'jabber.disktree.net';
	static var IP = 'localhost';
	static var HTTP = 'http';
	static var PASSWORD = 'test';
	static var RESOURCE = 'hxmpp';

	static var stream : Stream;

	static function onMessage( m : xmpp.Message ) {

		// Avoid processing of delayed messages
		if( xmpp.Delayed.fromPacket( m ) != null )
			return;

		// Get occupant jid from packet 'from' field
		var jid = new JID( m.from );
		
		trace( 'Received message from ${jid.bare} at resource: ${jid.resource}' );
		
		// Send a response message
		stream.sendPacket( new xmpp.Message( m.from, "Hello darling aka "+jid.node ) );
	}

	static function main() {

		trace( "Echo client" );

		var jid = new JID( '$USER@$SERVER' );

		#if (js&&!nodejs)
		var cnx = new jabber.BOSHConnection( SERVER, '$SERVER/$HTTP' );
		#else
		var ip = (IP != null) ? IP : jid.domain;
		var cnx = new jabber.SocketConnection( ip, 5222 );
		#end

		stream = new Stream( cnx );
		stream.onOpen = function() {
			var auth = new Authentication( stream, [
				//new jabber.sasl.PlainMechanism()
				new jabber.sasl.MD5Mechanism()
			] );
			auth.onFail = function(e) {
				trace( 'Authentication failed ($jid)' );
				stream.close( true );
			}
			auth.onSuccess = function() {
				trace( "Authenticated as "+stream.jid );
				new jabber.MessageListener( stream, onMessage ); // Listen for messages
				stream.sendPresence(); // Send initial presence 
			}
			auth.start( PASSWORD, RESOURCE ); // Start authentication
		}
		stream.onClose = function(?e) {
			if( e == null )
				trace( 'XMPP stream closed' );
			else
				trace( e );
		}
		stream.open( jid.bare ); // Open xml stream
	}

}
