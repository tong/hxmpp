
/**
	Legacy SSL (port 5223)
*/
class App {

	static function main() {

		//trace( sys.crypto.Base64.encode('tongtest') ); return;
		//trace( sys.crypto.Base64.encode('a') );


		var creds = XMPPClient.getAccountFromFile();
		trace(creds);

		//var cnx = new jabber.SocketConnection( creds.ip, 5222 );
		var cnx = new jabber.SecureSocketConnection( creds.ip, 5223 );

		#if !php
		//var s : sys.ssl.Socket = cnx.socket;
		//s.setCertLocation( '/etc/ssl/certs/ca-certificates.crt', '/etc/ssl/certs' );
		#end
		
		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function() {
			trace( "XMPP stream opened" );
			var auth = new jabber.client.Authentication( stream, [
				//new jabber.sasl.MD5Mechanism()
				new jabber.sasl.PlainMechanism()
			] );
			auth.onSuccess = function() {
				trace( "Authenticated as: "+stream.jid.toString() );
				stream.sendPresence();
			}
			auth.start( creds.password, XMPPClient.getPlatformResource() );
		}
		stream.onClose = function(?e) {
			trace( "XMPP stream closed" );
			if( e != null ) trace( e );
		}
		trace( "Connecting to "+creds.ip+" ..." );
		try {
			stream.open( creds.user+"@"+creds.host );
		} catch(e:Dynamic) {
			trace(e);
		}

	}
	
}
