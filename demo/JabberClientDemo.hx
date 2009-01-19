
import jabber.ServiceDiscovery;
import jabber.SocketConnection;
import jabber.client.NonSASLAuthentication;
import jabber.client.Roster;
import jabber.client.Stream;
import jabber.client.VCardTemp;


/**
	A basic jabber client.
	
	Action taking place is:
	* open xmpp stream
	* login
	* load roster
	* load vcard
	* discover server infos
	* discover server items
	
*/
class JabberClientDemo {
	
	static var stream : Stream;
	static var roster : Roster;
	static var service : ServiceDiscovery;
	static var vcard : VCardTemp;
	
	static function init() {
		var cnx = new SocketConnection( "127.0.0.1", 5222 );
		stream = new Stream( new jabber.JID( "hxmpp@disktree" ), cnx );
		stream.onError = function(s,e) { trace( "Stream error: "+e ); };
		stream.onClose = function(s) { trace( "Stream to: "+stream.jid.domain+" closed." ); } ;
		stream.onOpen = function(s) {
			trace( "Jabber stream to "+stream.jid.domain+" opened" );
			var auth = new NonSASLAuthentication( stream );
			auth.onSuccess = loginSuccess;
			auth.onFailed = function(e) {
				trace( "Login failed "+e.name );
			};
			auth.authenticate( "test", "norc" );
		};
		trace( "Initializing stream...\n" );
		try {
			stream.open();
		} catch( e : error.SocketConnectionError ) {
			trace( "Socket connection error " );
			trace(e);
		}
	}
	
	static function loginSuccess( s : Stream ) {
		
		trace( "Logged in as "+ s.jid.node+" at "+s.jid.domain );
		
		#if !JABBER_SOCKETBRIDGE
		// The socketbridge handles keepalive on its own.
		var keepAlive = new net.util.KeepAlive( cast( stream.cnx, jabber.SocketConnection ).socket ).start();
		#end
		
		roster = new Roster( s );
		roster.load();
		roster.onLoad = function( r : Roster ) {
			trace( "ROSTER LOADED:" );
			for( item in r.items ) {
				trace( "\t"+item.jid );
			}
		};
		
		vcard = new VCardTemp( stream );
		vcard.onLoad = function(d,node,vc) {
			trace( "VCARD LOADED: "+node );
		};
		vcard.load();
		
		/* TODO
		service = new ServiceDiscovery( stream );
		service.onInfo = function( sd, e ) {
			trace( "SERVICE INFO RESULT: "+e.from );
			trace( "\tIDENTITIES: ");
			for( identity in e.packet.identities ) trace( "\t\t"+identity );
			trace( "\tFEATURES: ");
			for( feature in e.packet.features ) trace( "\t\t"+feature );
			
		};
		service.discoverItems( "disktree" );
		service.discoverInfo( "disktree" );
	*/
	}
	
	static function main() {
		
		#if JABBER_DEBUG jabber.util.XMPPDebug.redirectTraces(); #end
		
		#if JABBER_SOCKETBRIDGE
		jabber.SocketBridgeConnection.initDelayed( "f9bridge", init );
		#else
		init();
		#end
	}
}
