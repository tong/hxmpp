package jabber;

#if JABBER_CLIENTLIB
import jabber.Chat;
import jabber.ChatStateNotification;
import jabber.SocketConnection;
import jabber.client.MUChat;
import jabber.client.NonSASLAuthentication;
import jabber.client.Roster;
import jabber.client.SASLAuthentication;
import jabber.client.Stream;
import jabber.client.VCardTemp;
import xmpp.DataForm;
import xmpp.DelayedDelivery;
//..
#end


/**
	[-]×|V||º|º<br/>
	
	If you want use hxmpp from plain javascript you have to compile this class including
	all required class imports.  By default it inlucdes the imports for all classes availale.
*/
class Lib {
	
	/**
		Current version: 0.2
		Next version: 0.2.1
	*/
	public static var VERSION = "0.2";
	
	
	#if JABBER_CLIENTLIB
	
	static function init( ?bridgeName : String = "f9bridge" ) {
		jabber.SocketBridgeConnection.init( bridgeName, initialized );
	}
	static function initialized() {
		trace( "Socket bridge hopefuly initialized" );
	}
	
	#end // JABBER_SOCKETBRIDGE
	
}
