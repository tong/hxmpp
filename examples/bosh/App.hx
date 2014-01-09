
import jabber.BOSHConnection;
import jabber.client.Stream;
import jabber.client.Authentication;

/**
	Use http/bosh to connect with xmpp server
*/
class App {

	static function init() {

		var creds = XMPPClient.readArguments();

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
			trace(e);
			if( e == null )
				trace( 'XMPP stream closed' );
			else
				trace( 'XMPP stream error : $e' );
			cnx.disconnect();
		}
		stream.open( creds.jid );
	}

	static function main() {
		#if flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		init();
		#elseif nodejs
		init();
		#elseif js
		js.Browser.window.onload = function(_){ init(); }
		#else
		init();
		#end
	}

}
