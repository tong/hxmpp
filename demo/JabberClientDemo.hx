
import jabber.ServiceDiscovery;
import jabber.SocketConnection;
import jabber.client.NonSASLAuthentication;
import jabber.client.Roster;
import jabber.client.Stream;
import jabber.client.VCardTemp;


class JabberClientDemo {
	
	static var stream : Stream;
	static var roster : Roster;
	static var service : ServiceDiscovery;
	static var vcard : VCardTemp;
	
	static function init() {
		var cnx = new SocketConnection( "127.0.0.1", 5222 );
		stream = new Stream( new jabber.JID( "tong@disktree" ), cnx, "1.0" );
		stream.onError = function(s,err) { trace( "Stream ERROR: " + err ); };
		stream.onClose = function(s) { trace( "Stream to: "+s.jid.domain+" closed." ); } ;
		stream.onOpen = function(s) {
			trace( "Jabber stream to "+stream.jid.domain+" opened" );
			var auth = new NonSASLAuthentication( stream );
			auth.onSuccess = loginSuccess;
			auth.onFailed = function(s) { trace( "LOGIN FAILED" ); };
			auth.authenticate( "test", "norc" );
		};
		trace( "Initializing stream..." );
		stream.open();
	}
	
	static function loginSuccess( s ) {
		
		trace( "Logged in as "+ s.jid.node+" at "+s.jid.domain );
		#if !( js || SOCKET_BRIDGE )
		var keepAlive = new net.util.KeepAlive( cast( stream.connection, jabber.SocketConnection ).socket ).start();
		#end
		
		roster = new Roster( stream );
		roster.onAvailable = function( r : Roster ) {
			trace( "ROSTER LOADED:" );
			for( entry in r.entries ) {
				trace( "\t"+entry.jid );
			}
		};
		roster.load();
		
		vcard = new VCardTemp( stream );
		vcard.onLoad = function(vc) {
			trace( "VCARD LOADED: "+vc.from );
		};
		vcard.load();
		
		service = new ServiceDiscovery( stream );
		service.onInfo = function( e ) {
			trace( "SERVICE INFO RESULT: "+e.from );
			trace( "\tIDENTITIES: ");
			for( identity in e.identities ) trace( "\t\t"+identity );
			trace( "\tFEATURES: ");
			for( feature in e.features ) trace( "\t\t"+feature );
			
		};
		service.discoverInfo( "account@disktree" );
	}
	
	static function main() {
		
		jabber.util.XMPPDebug.redirectTraces();
		
		#if JABBER_SOCKETBRIDGE
		trace( "Using socket bridge to connect" );
		jabber.SocketBridgeConnection.init( "f9bridge", init );
		
		#else
		init();
		
		#end
	}
}
