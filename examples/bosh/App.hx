
import jabber.BOSHConnection;
import jabber.client.Stream;
import jabber.client.Authentication;

/**
	Use http/bosh stream connection
*/
class App {

	static function login() {

		var user = 'romeo';
		var server = 'jabber.disktree.net';
		var password = 'test';
		var ip = 'localhost';
		var http = '$ip/http';

		var cnx = new BOSHConnection( server, http, 1, 30, false );
		
		#if (cpp||neko||nodejs)
		cnx.ip = ip;
		cnx.port = 80; //7070;
		#end

		var stream = new Stream( cnx );
		stream.onOpen = function() {
			trace( 'XMPP stream opened' );
			var auth = new Authentication( stream, [
				//new jabber.sasl.MD5Mechanism(),
				new jabber.sasl.PlainMechanism()
			] );
			auth.onFail = function(e) {
				trace( 'Authentication failed (${stream.jid}) '+e );
				stream.close( true );
			}
			auth.onSuccess = function() {
				trace( 'Authenticated as ${stream.jid}' );
				stream.sendPresence();
			}
			auth.start( password, 'anything' );
		}
		stream.onClose = function(?e) {
			trace( (e == null) ? 'XMPP stream closed' : e );
		}
		stream.open( '$user@$server' );
	}

	static function main() {
		
		#if flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end

		#if (js&&!nodejs)
		js.Browser.window.onload = function(_){ login(); }
		#else
		login();
		#end
	}

}
