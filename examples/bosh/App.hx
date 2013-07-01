
import jabber.client.Stream;
import jabber.client.Authentication;

class App {

	static function main() {

		#if flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		var creds = XMPPClient.getAccountFromFile( 'a' );
		trace( creds );

		var cnx = new jabber.BOSHConnection( creds.host, creds.http, 1, 30, false );
		#if (cpp||neko||nodejs)
		cnx.ip = creds.ip;
		cnx.port = 7070;
		#end

		var stream = new Stream( cnx );
		stream.onOpen = function() {
			trace( 'XMPP stream opened' );
			var auth = new Authentication( stream, [
				new jabber.sasl.PlainMechanism()
				//new jabber.sasl.MD5Mechanism()
			] );
			auth.onFail = function(e) {
				trace( "Authentication failed ("+stream.jid+")" );
				stream.close( true );
			}
			auth.onSuccess = function() {
				trace( "Authenticated as "+stream.jid );
				stream.sendPresence();
			}
			auth.start( creds.password, 'hxmpp-bosh' );
		}
		stream.onClose = function(?e) {
			if( e == null )
				trace( 'XMPP stream closed' );
			else
				trace( 'XMPP stream error : $e' );
			cnx.disconnect();
		}
		stream.open( creds.user+'@'+creds.host );
	}

}
