
/**
	Example/Test of using the socket implementation of chrome-apps.

	See: https://github.com/tong/chrome.app
*/
class App {
	
	static function main() {
		var creds = XMPPClient.getAccountCredentials();
		var jid = creds.user+'@'+creds.host;
		var cnx = new jabber.SocketConnection( creds.ip );
		trace( 'Connecting to [${cnx.host}] ...' );
		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function(){
			trace("XMPP stream opened");
			var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
			auth.onSuccess = function(){
				trace( "Authenticated as: "+stream.jid.s );
				stream.sendPresence();
			}
			auth.onFail = function(e){
				trace( 'Authentication failed! ($jid)(${creds.password})' );
			}
			auth.start( creds.password, "hxmpp" );
		}
		stream.onClose = function(?e){
			trace( "XMPP stream closed" );
			if( e != null ) trace(e);
		};
		stream.open( jid );
	}
	
}
