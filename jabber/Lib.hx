package jabber;

#if JABBER_LIBCLIENT
// this is the doc setup->
import jabber.Chat;
import jabber.ChatStateNotification;
import jabber.MessageListener;
import jabber.ServiceDiscovery;
import jabber.ServiceDiscoveryListener;
import jabber.SocketConnection;
import jabber.client.MUChat;
import jabber.client.NonSASLAuthentication;
import jabber.client.Roster;
import jabber.client.SASLAuthentication;
import jabber.client.Stream;
import jabber.client.VCardTemp;
import jabber.component.Stream;
import jabber.util.XMPPDebug;
import jabber.util.ResourceAccount;
import xmpp.DataForm;
import xmpp.DelayedDelivery;
#end

#if JABBER_SOCKETBRIDGE
import jabber.SocketConnection;
#end


/**
	[-]×|V||º|º<br/>
	
	If you want use hxmpp from plain javascript you have to compile this class including
	all required class imports.
*/
class Lib {
	
	#if JABBER_DEBUG
	
	/**
		Current version: 0.2
	*/
	public static var VERSION = "0.2";
	
	#end // JABBER_DEBUG
	
	
	#if JABBER_SOCKETBRIDGE
	
	static function initSocketBridge( ?id : String = "f9bridge" ) {
		jabber.SocketBridgeConnection.init( id, initialized );
	}
	static function initialized() {
		#if JABBER_DEBUG trace( "Socket bridge hopefuly initialized" ); #end
	}
	
	#end // JABBER_SOCKETBRIDGE
	
}
