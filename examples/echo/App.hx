
import jabber.JID;
import jabber.client.Stream;
import jabber.client.Authentication;

/**
	Simple xmpp echo client
*/
class App {

	static var JID = 'hxmpp@jabber.disktree.net';
	static var PASSWORD = 'test';
	static var IP = 'jabber.disktree.net';
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
		
		//TODO
		//TODO clean this up and test with different servers 
		//TODO
		//TODO
		//TODO
		var jid = new JID( JID );
		//var ip = "jabber.spektral.at"; //(IP != null) ? IP : jid.domain;
		var ip = (IP != null) ? IP : jid.domain;

		trace(ip);
		
		var cnx = new jabber.SocketConnection( ip, 5222 );
		stream = new Stream( cnx );
		stream.onOpen = function() {
			var auth = new Authentication( stream, [
				new jabber.sasl.MD5Mechanism()
				//new jabber.sasl.PlainMechanism()
			] );
			auth.onFail = function(e) {
				trace( 'Authentication failed ($jid)' );
				stream.close( true );
			}
			auth.onSuccess = function() {
				trace( "Authenticated as "+stream.jid );
				new jabber.MessageListener( stream, onMessage ); // --- listen for messages
				stream.sendPresence(); // --- send initial presence 
			}
			auth.start( PASSWORD, RESOURCE );
		}
		stream.onClose = function(?e) {
			if( e == null )
				trace( 'XMPP stream closed' );
			else
				trace( e );
		}
		stream.open( jid.bare );
	}

}
