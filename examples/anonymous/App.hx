
import jabber.client.Stream;
import jabber.client.Authentication;
import jabber.sasl.AnonymousMechanism;

/**
	Anonymous client login
*/
class App {

	static function main() {
		
		var ip = 'localhost';

		#if sys
		var args = Sys.args();
		if( args.length > 0 ) ip = args[0];
		#end

		var cnx = new jabber.SocketConnection( ip );
		var stream = new Stream( cnx );
		stream.onClose = function(?e) {
			trace( (e == null) ? 'XMPP stream closed' : e );
		}
		stream.onOpen = function() {
			var anonAllowed = false;
			var serverMechs = stream.serverFeatures.get( "mechanisms" );
			for( m in serverMechs ) {
				if( m.firstChild().nodeValue == AnonymousMechanism.NAME  ) {
					anonAllowed = true;
					break;
				}
			}
			if( !anonAllowed ) {
				trace( "Server does not support anonymous login" );
				return;
			}
			var auth = new Authentication( stream, [new AnonymousMechanism()] );
			auth.onSuccess = function() {
				trace( 'Anonymous session ready: ${stream.jid}' );
				stream.sendPresence();
			}
			auth.start( null, null ); // Null for anonymous authentication
		}
		stream.open( null ); // Null for anonymous session
	}
	
}
