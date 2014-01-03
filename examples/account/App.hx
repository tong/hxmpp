
import jabber.JID;
import jabber.client.Stream;
import jabber.client.Account;
import jabber.client.Authentication;

/**
	Register/Unregister an client account at server.
*/
@:require(sys)
class App {
	
	static var stream : Stream;
	
	static function openStream( jid : String, f : Void->Void ) {
		var cnx = new jabber.SocketConnection();
		stream = new Stream( cnx );
		stream.onOpen = f;
		stream.onClose = function(?e) {
			if( e != null ) error( "XMPP error: "+e );
			Sys.exit(0);
		}
		stream.open( jid );
	}

	static function register( username : String, host : String, password : String, ?name : String, ?email : String ) {
		openStream( null, function(){
			var acc = new Account( stream );
			acc.onRegister = function( node : String ) {
				trace( 'Account successfully registerd [$node]' );
				stream.close( true );
			}
			acc.onError = function( e ) {
				trace( e.toString() );
				stream.close( true );
			}
			acc.register( new xmpp.Register( username, password, email, name ) );
		});
	}
	
	static function unregister( jid : String, password : String ) {
		openStream( jid, function(){
			var auth = new Authentication( stream, [new jabber.sasl.MD5Mechanism(),new jabber.sasl.PlainMechanism()] );
			auth.onFail = function(info) {
				error( 'Authentication failed: $info' );
			}
			auth.onSuccess = function() {
				var acc = new Account( stream );
				acc.onRemove = function() {
					trace( 'Account successfully removed' );
					stream.close( true );
				}
				acc.onError = function( e ) {
					stream.close( true );
					error( e.toString() );
				}
				acc.remove();
			}
			auth.start( password, 'hxmpp' );
		});
	}

	static function error( info : Dynamic ) {
		Sys.println( info );
		Sys.exit(1);
	}

	static function main() {
		var argHandler = hxargs.Args.generate([
			@doc( 'Register account' ) ['--register','-r'] => function(credentials:String) {
				var creds = credentials.split( ' ' );
				if( !JID.isValid( creds[0] ) ) error( "Invalid jid" );
				var jid = new JID( creds[0] );
				register( jid.node, jid.domain, creds[1], creds[2], creds[3] );
			},
			@doc( 'Unregister account' ) ['--unregister','-u'] => function(credentials:String) {
				var creds = credentials.split( ' ' );
				if( creds.length != 2 ) error( "Invalid input" );
				unregister( creds[0], creds[1] );
			},
			_ => function(arg:String) throw "Unknown command: " +arg
		]);
		var args = Sys.args();
		if( args.length < 1 ) {
			Sys.println( argHandler.getDoc() );
			Sys.exit(0);
		}
		argHandler.parse( args );
	}
	
}
