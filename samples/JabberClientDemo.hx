
import jabber.ServiceDiscovery;
import jabber.SocketConnection;
import jabber.client.NonSASLAuthentication;
import jabber.client.Stream;

/**
	A basic jabber client.
*/
class JabberClientDemo {
	
	static function main() {
		
		#if flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		#if XMPP_DEBUG
		jabber.XMPPDebug.redirectTraces();
		#end
		
		#if JABBER_SOCKETBRIDGE
		jabber.SocketBridgeConnection.initDelayed( "f9bridge", init );
		#else
		init();
		#end
	}
	
	static var stream : Stream;
	
	static function init() {
		stream = new Stream( new jabber.JID( "hxmpp@disktree" ), new SocketConnection( "127.0.0.1", Stream.defaultPort ) );
		stream.onError = function(?e) { trace( "Stream error: "+e ); };
		stream.onClose = function() { trace( "Stream to: "+stream.jid.domain+" closed." ); } ;
		stream.onOpen = function() {
			trace( "XMPP stream to "+stream.jid.domain+" opened" );
			/*
			var auth = new NonSASLAuthentication( stream );
			auth.onSuccess = handleLogin;
			auth.onFail = function(?e) {
				trace( "Login failed "+e.name );
			};
			*/
			var mechanisms = new Array<net.sasl.Mechanism>();
			mechanisms.push( new net.sasl.PlainMechanism() );
			var auth = new jabber.client.SASLAuthentication( stream, mechanisms );
			auth.onSuccess = handleLogin;
			auth.onFail = function(?e) {
				trace( "Authentication failed", "warn" );
			};
			auth.authenticate( "test", #if neko "NEKO" #elseif flash9 "FLASH" #elseif js "JS" #elseif php "PHP" #end );
		};
		trace( "Initializing XMPP stream ..." );
		try {
			stream.open();
		} catch( e : error.SocketConnectionError ) {
			trace( "Socket connection error", "error" );
			trace(e);
		}
	}
	
	static function handleLogin() {

		trace( "Logged in as "+ stream.jid.node+" at "+stream.jid.domain );
		
		// load roster
		var roster = new jabber.client.Roster( stream );
		roster.presence.change( null, "online" );
		roster.load();
		roster.onLoad = function() {
			trace( "Roster loaded:" );
			for( item in roster.items ) {
				trace( "\t"+item.jid );
			}
		};
		
		// load own vcard
		var vcard = new jabber.client.VCardTemp( stream );
		vcard.onLoad = function(d,node,vc) {
			if( node == null )
				trace( "VCard loaded." );
			else
				trace( "VCard from "+node+" loaded." );
		};
		vcard.load();
		
		// load server disco infos
		var service = new ServiceDiscovery( stream );
		service.onInfo = function( node : String, info : xmpp.disco.Info ) {
			trace( "Service info result: "+node );
			trace( "\tIdentities: ");
			for( identity in info.identities )
				trace( "\t\t"+identity );
			trace( "\tFeatures: ");
			for( feature in info.features )
				trace( "\t\t"+feature );
			
		};
		service.discoverItems( stream.jid.domain );
		service.discoverInfo( stream.jid.domain );
	}
	
}
