
/**
	A simple XMPP client responding with a "Hello" to every message.
*/
class EchoRoboter {
	
	static var HOST = "disktree";
	static var IP = "127.0.0.1";
	static var JID = "hxmpp@"+HOST;
	static var PASS = "mypassword";
        
	static var stream : jabber.client.Stream;
	
	static function main() {
		trace( "XMPP echo roboter" );
		#if js
		var cnx = new jabber.BOSHConnection( "disktree", "jabber" );
		#else
		var cnx = new jabber.SocketConnection( IP, 5222 );
		#end
		var jid = new jabber.JID( JID );
		stream = new jabber.client.Stream( jid, cnx );
		stream.onError = function(?e) {
			if( e == null ) trace( "XMPP stream with "+stream.host+" closed." );
			else trace( "An XMPP stream error occured: "+e );
		}
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
		if( xmpp.Delayed.fromPacket( m ) != null )
			return; // avoid processing offline sent messages
		var jid = new jabber.JID( m.from );
		trace( "Recieved message from "+jid.bare+" at resource:"+jid.resource );
		stream.sendPacket( new xmpp.Message( m.from, "Hello darling aka "+jid.node ) );
	}
}
