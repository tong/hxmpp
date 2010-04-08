
/**
	A simple XMPP client responding with a "Hello" to every message.
*/
class EchoRoboter {
	
	static var HOST = "disktree";
	static var IP = "127.0.0.1";
	static var JID = "hxmpp@"+HOST;
	static var PASS = "test";
	
	static var stream : jabber.client.Stream;
	
	static function main() {
		var cnx = new jabber.SocketConnection( IP, 5222 );
		var jid = new jabber.JID( JID );
		stream = new jabber.client.Stream( jid, cnx );
		stream.onOpen = function() {
			var auth = new jabber.client.SASLAuth( stream, [cast new jabber.sasl.MD5Mechanism()] );
			auth.onSuccess = function() {
				new jabber.MessageListener( stream, handleMessage );
				stream.sendPresence();
			}
			auth.authenticate( PASS, "HXMPP" );
		}
		stream.open();
	}
		
	static function handleMessage( m : xmpp.Message ) {
		trace( "Recieved message from "+m.from );
		stream.sendPacket( new xmpp.Message( m.from, "Hello" ) );
	}
}
