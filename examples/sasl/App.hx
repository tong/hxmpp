
/**
	Example/Test of SASL mechanisms
*/
class App {
	
	static function main() {
		
		var ip = "127.0.0.1";
		var jid = "romeo@disktree";
		
		#if (js&&!nodejs)
		var cnx = new jabber.BOSHConnection( "jabber.spektral.at", "jabber.spektral.at/jabber" );
		#else
		var cnx = new jabber.SocketConnection( ip, 5222, false );
		#end

		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function() {
			trace( "XMPP stream opened", "info" );
			var mechs : Array<jabber.sasl.Mechanism> = [
				new jabber.sasl.MD5Mechanism(),
				new jabber.sasl.PlainMechanism()
			];
			var auth = new jabber.client.Authentication( stream, mechs );
			auth.onSuccess = function() {
				trace( "Authenticated as: "+stream.jid.toString(), "info" );
				stream.sendPresence();
			}
			auth.start( "test", "thisistheresource" );
		}
		stream.onClose = function(?e) {
			trace( "XMPP stream closed" );
			if( e != null ) trace( e, "warn" );
		}
		trace( "Connecting ["+ip+","+jid+"] ..." );
		stream.open( new jabber.JID( jid ) );
	}
	
}
