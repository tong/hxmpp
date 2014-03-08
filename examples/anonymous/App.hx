
import jabber.client.Stream;
import jabber.client.Authentication;
import jabber.sasl.AnonymousMechanism;

/**
	Anonymous client login
*/
class App {

	static function main() {
		
		var server = 'localhost';

		#if sys
		var argHandler = hxargs.Args.generate([
			@doc( 'Jabber server hostname' ) ['--server','-s'] => function(name:String) { server = name; },
			_ => function(arg:String) throw "Unknown command: " +arg
		]);
		var args = Sys.args();
		if( args.length < 1 ) {
			Sys.println( argHandler.getDoc() );
			Sys.exit(0);
		}
		argHandler.parse( args );
		#end

		var cnx = new jabber.SocketConnection( server );
		var stream = new Stream( cnx );
		stream.onClose = function(?e) {
			trace( (e == null) ? 'XMPP stream closed' : e );
		}
		stream.onOpen = function() {
			var anonAllowed = false;
			var serverMechs = stream.server.features.get( "mechanisms" );
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
