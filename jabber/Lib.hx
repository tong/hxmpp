package jabber;

#if JABBER_SOCKETBRIDGE
import jabber.SocketConnection;
#end

class Lib {
	
	#if JABBER_DEBUG
	public static var VERSION = "0.2.3";
	#end
	
	
	#if JABBER_SOCKETBRIDGE
	
	public static var defaultSocketBridgeID = "f9bridge";
	
	static function initSocketBridge( ?id : String ) {
		if( id == null ) id = defaultSocketBridgeID;
		jabber.SocketBridgeConnection.initDelayed( id, initialized );
	}
	static function initialized() {
		#if JABBER_DEBUG
		trace( "Socket bridge hopefuly initialized" );
		#end
	}
	#end
	
}
