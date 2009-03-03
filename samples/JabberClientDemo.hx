
import jabber.ServiceDiscovery;
import jabber.SocketConnection;
import jabber.client.NonSASLAuthentication;
import jabber.client.Stream;


/**
	A basic jabber client.
	
	Action taking place is:
	* open xmpp stream
	* login
	* load roster
	* load vcard
	* discover server infos+items
	
*/
class JabberClientDemo {
	
	static var stream : Stream;
	
	static function init() {
		
		trace("HXMPP");
		
		stream = new Stream( new jabber.JID( "hxmpp@disktree" ), new SocketConnection( "127.0.0.1", Stream.defaultPort ) );
		stream.onError = function(?e) { trace( "Stream error: "+e ); };
		stream.onClose = function() { trace( "Stream to: "+stream.jid.domain+" closed." ); } ;
		stream.onOpen = function() {
			trace( "Jabber stream to "+stream.jid.domain+" opened" );
			var auth = new NonSASLAuthentication( stream );
			auth.onSuccess = handleLogin;
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
	
	static function handleLogin() {
		
		trace( "Logged in as "+ stream.jid.node+" at "+stream.jid.domain );
		
		#if (neko||flash||js )
		new net.util.KeepAlive( cast( stream.cnx, jabber.SocketConnection ).socket, 1000 ).start();
		#end
		
		var roster = new jabber.client.Roster( stream );
		roster.presence.change( null, "online" );
		roster.load();
		roster.onLoad = function(r) {
			trace( "Roster loaded:" );
			for( item in r.items ) {
				trace( "\t"+item.jid );
			}
		};
		
		var vcard = new jabber.client.VCardTemp( stream );
		vcard.onLoad = function(d,node,vc) {
			if( node == null )
				trace( "VCard loaded." );
			else
				trace( "VCard from "+node+" loaded." );
		};
		vcard.load();
		
		/*
		var service = new ServiceDiscovery( s );
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
		#if js
		//haxe.Timer.delay( function() { stream.close(true); }, 1000 );
		#end
	}
	
	static function main() {
		#if XMPP_DEBUG
		jabber.XMPPDebug.redirectTraces();
		#end
		
		#if JABBER_SOCKETBRIDGE
		jabber.SocketBridgeConnection.initDelayed( "f9bridge", init );
		#else
		init();
		#end
	}
}
