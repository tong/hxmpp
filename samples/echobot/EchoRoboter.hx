
/**
	A simple XMPP client responding with a "Hello" to every message.
*/
class EchoRoboter {
	
	static var HOST = "example.com";
	static var IP = "127.0.0.1";
	static var JID = "user@"+HOST;
	static var PASSWORD = "mypassword";
    static var RESOURCE = "HXMPPEchoRoboter";
       
	static var stream : jabber.client.Stream;
	
	static function main() {
		
		if( haxe.Firebug.detect() ) haxe.Firebug.redirectTraces(); 
		
		#if ( js && !nodejs && !JABBER_SOCKETBRIDGE )
		var cnx = new jabber.BOSHConnection( HOST, IP+"/jabber" );
		#else
		var cnx = new jabber.SocketConnection( IP, 5222 );
		#end
		
		var jid = new jabber.JID( JID );
		stream = new jabber.client.Stream( jid, cnx );
		stream.onClose = function(?e) {
			if( e == null )
				trace( "XMPP stream closed." );
			else
				trace( "An XMPP stream error occured: "+e );
		}
		stream.onOpen = function() {
			//var auth = new jabber.client.SASLAuth( stream, [cast new jabber.sasl.MD5Mechanism()] );
			var auth = new jabber.client.SASLAuth( stream, [cast new jabber.sasl.AnonymousMechanism()] );
			auth.onSuccess = function() {
				new jabber.MessageListener( stream, handleMessage );
				stream.sendPresence();
			}
			auth.authenticate( PASSWORD, RESOURCE );
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
