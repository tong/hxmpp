
import jabber.BOSHConnection;
import jabber.client.Stream;
import jabber.client.Authentication;

/**
	Use http/bosh stream connection
*/
class App {

	static function init() {

		var creds = XMPPClient.readArguments();
		creds.http = 'jabber.disktree.net/http';

		var cnx = new BOSHConnection( creds.ip, creds.http, 1, 30, false );
		
		#if (cpp||neko||nodejs)
		cnx.ip = creds.ip;
		cnx.port = 7070;
		#end

		var stream = new Stream( cnx );
		stream.onOpen = function() {
			trace( 'XMPP stream opened' );
			var auth = new Authentication( stream, [
				new jabber.sasl.MD5Mechanism(),
				new jabber.sasl.PlainMechanism()
			] );
			auth.onFail = function(e) {
				trace( 'Authentication failed (${stream.jid})' );
				stream.close( true );
			}
			auth.onSuccess = function() {
				trace( 'Authenticated as ${stream.jid}' );
				stream.sendPresence();
			}
			auth.start( creds.password, 'hxmpp-bosh' );
		}
		stream.onClose = function(?e) {
			trace( (e == null) ? 'XMPP stream closed' : e );
		}
		stream.open( creds.jid );
	}

	static function main() {
		
		#if flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		init();
		
		#elseif js
			#if nodejs
			init();
			#else
			js.Browser.window.onload = function(_){ init(); }
			#end

		#else
		init();

		#end
	}

}
