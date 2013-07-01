
import XMPPClient;

/**
	Example/Test of SASL mechanisms for authentication
*/
class App {
	
	static function main() {

		#if ssl
		
		//trace(sys.crypto.MD5.encode( 'test' ));

		/*
		var b = new StringBuf();
		b.add( String.fromCharCode( 0 ) );
		b.add( 'tong' );
		b.add( String.fromCharCode( 0 ) );
		b.add( 'test' );
		var s : String = b.toString();
		trace(sys.crypto.Base64.encode( haxe.Utf8.encode(s) ) );
		return;
		*/
		#end

		var creds : AccountCredentials = XMPPClient.getAccountFromFile();
		trace( creds );
		
		#if (js&&!nodejs)
		var cnx = new jabber.BOSHConnection( creds.host, creds.http );
		#else
		var cnx = new jabber.SocketConnection( creds.ip, creds.port, false );
		#end

		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function() {
			
			trace( "XMPP stream opened" );
			
			var mechs : Array<jabber.sasl.Mechanism> = [
				new jabber.sasl.MD5Mechanism(),
				//new jabber.sasl.PlainMechanism(),
				//new jabber.sasl.LOGINMechanism(),
			];
			var auth = new jabber.client.Authentication( stream, mechs );
			auth.onSuccess = function() {
				trace( "Authenticated as: "+stream.jid.toString() );
				stream.sendPresence();
			}
			auth.onFail = function(e) {
				trace( "Authentication failed: "+e );
			}
			auth.start( creds.password, XMPPClient.getPlatformResource() );
		}
		stream.onClose = function(?e) {
			trace( "XMPP stream closed" );
			if( e != null ) trace( e );
		}
		stream.open( creds.user+"@"+creds.host );
	}
	
}
