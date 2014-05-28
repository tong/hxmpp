
/**
	Legacy SSL (port 5223)
*/
class App {

	static function main() {

		var creds = XMPPClient.readArguments();

		//var cnx = new jabber.SocketConnection( 'localhost', 5223, true );
		var cnx = new jabber.SecureSocketConnection( creds.ip, 5223 );

		#if !php
		cnx.socket.setCertLocation( '/etc/ssl/certs/ca-certificates.crt', '/etc/ssl/certs' );
		#end
		
		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function() {
			trace( "XMPP stream opened" );
			var auth = new jabber.client.Authentication( stream, [
				new jabber.sasl.PlainMechanism()
			] );
			auth.onSuccess = function() {
				trace( "Authenticated as: "+stream.jid );
				stream.sendPresence();
			}
			auth.start( creds.password );
		}
		stream.onClose = function(?e) {
			trace( "XMPP stream closed" );
			if( e != null ) trace( e );
		}
		trace( "Connecting to "+creds.ip+" ..." );
		try stream.open( creds.jid ) catch(e:Dynamic) {
			trace(e);
		}

	}
	
}
