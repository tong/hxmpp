
#if JABBER_SOCKETBRIDGE
import jabber.StreamSocketConnection;
#end


class App {
	
	static function main() {
		
		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		jabber.tool.XMPPDebug.setRedirection();
		
		#if JABBER_SOCKETBRIDGE
		trace( "Using JABBER_SOCKETBRIDGE" );
		jabber.SocketBridgeConnection.init( "f9bridge", init );
		
		#else
		init();

		#end
	}
	
	static function init() {
		trace( "initializing jabber client ..." );
		var acc = new jabber.util.ResourceAccount( "account" );
		var stream = new CustomStream( new jabber.JID( acc.jid ), acc.password, acc.host, acc.port );
		try {
			stream.open();
		} catch( e : Dynamic ) {
			trace( "JABBER ERROR: " + e );
		}
	}
	
}