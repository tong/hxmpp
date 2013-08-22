
/**
	Anonymous client login
*/
class App {

	static function main() {

		var cnx = new jabber.SocketConnection( "localhost" );
		var stream = new jabber.client.Stream( cnx );
		
		stream.onClose = function(?e) {
			if( e == null ) trace( "XMPP stream closed." );
			else trace( "XMPP stream error: "+e );
		}
		stream.onOpen = function() {
			var anonymouseLoginAllowed = false;
			var serverMechs = stream.server.features.get( "mechanisms" );
			for( m in serverMechs ) {
				if( m.firstChild().nodeValue == jabber.sasl.AnonymousMechanism.NAME  ) {
					anonymouseLoginAllowed = true;
					break;
				}
			}
			if( !anonymouseLoginAllowed ) {
				trace( "Server does not support anonymous login" );
				return;
			}
			var auth = new jabber.client.Authentication( stream, [new jabber.sasl.AnonymousMechanism()] );
			auth.onSuccess = function() {
				stream.sendPresence();
				trace( "Anonymous session connected as: "+stream.jid.toString() );
			}
			auth.start( null, null ); //pass null for anonymous authentication
		}
		stream.open( null );
	}
	
}
