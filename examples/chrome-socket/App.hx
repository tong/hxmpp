
/**
	Example/Test of using the socket api of google-chrome packaged-apps.
	See: https://github.com/tong/chrome.app
*/
class App {
	
	static function main() {
	
		var ip = "localhost";
		var jid = "romeo@om";
		var password = "test";
		
		var cnx = new jabber.SocketConnection( ip );

		trace( "Connecting to ["+cnx.host+"] ..." );

		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function(){
			trace("XMPP stream opened");
			var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
			auth.onSuccess = function(){
				trace( "Authenticated as: "+stream.jid.s );
				stream.sendPresence();
			}
			auth.onFail = function(e){
				trace( "Authentication failed! ("+stream.jid.s+")("+password+")" );
			}
			auth.start( password, "HXMPP" );
		}
		stream.onClose = function(?e){
			trace("XMPP stream closed");
			if( e != null ) trace(e,"error");
		};
		stream.open( jid );
	}
	
}
