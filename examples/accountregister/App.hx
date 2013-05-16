
/**
	Register/Unregister XMPP client account.
*/
class App {
	
	static var node = 'testaccount';
	static var pass = 'mypassword';
	
	static function main() {
		register();
		//unregister();
	}
	
	static function register() {
		var cnx = new jabber.SocketConnection();
		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function() {
			var acc = new jabber.client.Account( stream );
			acc.onRegister = function( node : String ) {
				trace( 'Account successfully registerd ['+node+']' );
				stream.close( true );
			}
			acc.onError = function( e ) {
				trace( e.toString() );
				stream.close( true );
			}
			acc.register( new xmpp.Register( node, pass, 'node@example.com', 'Captain Kirk' ) );
		}
		stream.onClose = function(?e) {
			if( e != null ) {
				trace( "XMPP stream error: "+e );
			}
		}
		stream.open( null );
	}
	
	static function unregister() {
		var cnx = new jabber.SocketConnection( 'localhost' );
		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function() {
			var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
			auth.onSuccess = function() {
				var acc = new jabber.client.Account( stream );
				acc.onRemove = function() {
					trace( 'Account successfully removed' );
					stream.close( true );
				}
				acc.onError = function( e ) {
					trace( e.toString() );
					stream.close( true );
				}
				acc.remove();
			}
			auth.start( pass, 'HXMPP' );
		}
		stream.onClose = function(?e) {
			if( e != null ) {
				trace( "XMPP stream error: "+e );
			}
		}
		stream.open( new jabber.JID( node+'@disktree' ) );
	}
	
}
