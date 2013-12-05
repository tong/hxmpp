
import jabber.client.Stream;
import jabber.client.Authentication;

/**
	Use http/bosh to connect with xmpp server
*/
class App {

	static function init() {

		var creds = XMPPClient.getAccountCredentials( "romeo" );

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
			trace(e);
			if( e == null )
				trace( 'XMPP stream closed' );
			else
				trace( 'XMPP stream error : $e' );
			cnx.disconnect();
		}
		stream.open( creds.user+'@'+creds.host );
	}

	static function onClick(e) {
		init();
		#if flash
		flash.Lib.current.stage.removeEventListener( flash.events.MouseEvent.MOUSE_DOWN, onClick );
		#elseif js
		js.Browser.document.getElementById('app-web').onclick = null;
		#end
	}
	
	static function main() {

		#if flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, function(e){ init(); } );

		#elseif nodejs
		init();

		#elseif js
		js.Browser.window.onload = function(_){
			js.Browser.document.getElementById('app-web').onclick = function(_){ init(); };
		}

		#else
		init();

		#end
	}

}
