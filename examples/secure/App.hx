
/**
	Legacy TLS (port 5223)
*/
class App {
	
	static function main() {
		
		var ip = "127.0.0.1";
		var jid = "romeo@disktree";
		
		var cnx = new jabber.SecureSocketConnection( ip );
		
		//var cnx = new jabber.SocketConnection( ip );
		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function() {
			trace( "XMPP stream opened", "info" );
			var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
			auth.onSuccess = function() {
				trace( "Authenticated as: "+stream.jid.toString(), "info" );
				stream.sendPresence();
			}
			auth.start( "test", XMPPClient.getDefaultResource() );
		}
		stream.onClose = function(?e) {
			trace( "XMPP stream closed" );
			if( e != null ) trace( e, "warn" );
		}
		trace( "Connecting ["+ip+","+jid+"] ..." );
		stream.open( new jabber.JID( jid ) );
	}
	
}
