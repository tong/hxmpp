
import jabber.client.Stream;

/**
	Calculates the MD5 challenge response for SASL authentication on a web server instead of locally.
	This allows to create xmpp/web based clients without including the (hardcoded) password in source code.
*/
class App {

	static inline var USER = "romeo";
	static inline var SERVER = "jabber.disktree.net";

	static var stream : Stream;

	static function main() {
		
		var cnx = new jabber.BOSHConnection( "localhost","localhost/http" );
		stream = new Stream( cnx );
		stream.onOpen = function(){
			
			trace( "XMPP stream opened" );
			
			var mech = new jabber.sasl.ExternalMD5Mechanism( "password-store.php" );
			//var mech = new jabber.sasl.MD5Mechanism();

			var auth = new jabber.client.Authentication( stream, [mech] );
			auth.onSuccess = function(){
				trace( "Successfully authenticated" );
				stream.sendPresence();
			}
			auth.onFail = function(e){
				trace( "Failed to authenticate: "+e );
			}
			auth.start( null, "hxmpp" );
		}
		stream.onClose = function(?e){
			trace( "Stream closed" );
			trace( e );
		}
		stream.open( '$USER@$SERVER' );
	}
}
