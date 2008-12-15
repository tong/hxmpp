package jabber;

#if JABBER_LIBCLIENT
// this is the doc setup->
import jabber.Chat;
import jabber.ChatStateNotification;
import jabber.MessageListener;
import jabber.ServiceDiscovery;
import jabber.ServiceDiscoveryListener;
import jabber.SocketConnection;
import jabber.client.MUC;
import jabber.client.NonSASLAuthentication;
import jabber.client.Roster;
import jabber.client.SASLAuthentication;
import jabber.client.Stream;
import jabber.client.VCardTemp;
import xmpp.DataForm;
import xmpp.Delayed;
#if JABBER_DEBUG
import jabber.util.XMPPDebug;
import jabber.util.ResourceAccount;
#end // JABBER_DEBUG
#end // JABBER_LIBCLIENT

#if JABBER_SOCKETBRIDGE
import jabber.SocketConnection;
#end


/**
	Modify the imports of this class file to (pre)compile a hxmpp library.
*/
class Lib {
	
	#if JABBER_DEBUG
	/** Current version: 0.2.1 */
	public static var VERSION = "0.2.1";
	#end // JABBER_DEBUG
	
	
	#if JABBER_SOCKETBRIDGE
	static function initSocketBridge( ?id : String = "f9bridge" ) {
		jabber.SocketBridgeConnection.initDelayed( id, initialized );
	}
	static function initialized() {
		#if JABBER_DEBUG trace( "Socket bridge hopefuly initialized" ); #end
	}
	#end // JABBER_SOCKETBRIDGE
	
}
