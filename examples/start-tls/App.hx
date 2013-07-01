
class App {
	
	static var ip = "127.0.0.1";
	static var jid = "romeo@disktree";
	static var password = "test";
	
	static function main() {
		
		#if flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		#if (js&&!nodejs)
		untyped swfobject.embedSWF('../../hxmpp/util/socketbridge/socketbridge_tls.swf','socketbridge','0','0','10');
		jabber.SocketConnection.init( 'socketbridge', function(error:String) {
			connect();
		}, 500 );
		
		#else
		connect();
		
		#end
	}
	
	static function connect() {
		var cnx = new jabber.SocketConnection( ip );
		var stream = new jabber.client.Stream( cnx );
		stream.onOpen = function() {
			trace( "XMPP stream opened" );
			trace( "The socket connection is secure: "+stream.cnx.secure );
			var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
			auth.onSuccess = function() {
				stream.sendPresence();
				new jabber.client.VCardTemp( stream ).load();
			}
			auth.start( password, "HXMPP" );
		}
		stream.onClose = function(?e) {
			trace( "XMPP stream closed", ( e != null ) ? "error" : "info" );
			if( e != null ) trace( e, "error" );
		}
		stream.open( jid );
	}
	
}
