
import jabber.ServiceDiscovery;
import jabber.SocketConnection;
import jabber.client.NonSASLAuthentication;
import jabber.client.Stream;
import jabber.client.Roster;
import jabber.client.VCardTemp;

/**
	Basic jabber client.
*/
class ClientDemo {
	
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
	static var roster : Roster;
	static var service : ServiceDiscovery;
	static var vcard : VCardTemp;
	
	static function init() {
		stream = new Stream( new jabber.JID( "hxmpp@disktree" ), new SocketConnection( "127.0.0.1", 5555 ) );
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
		stream.open();
	}
	
	static function handleLogin() {

		trace( "Logged in as "+ stream.jid.node+" at "+stream.jid.domain );
		
		// load server disco infos
		service = new ServiceDiscovery( stream );
		service.onInfo = handleDiscoInfo;
		service.onItems = handleDiscoItems;
		service.discoverItems( stream.jid.domain );
		service.discoverInfo( stream.jid.domain );
		
		// load roster
		roster = new jabber.client.Roster( stream );
		roster.presence.change( null, "online" );
		roster.load();
		roster.onLoad = handleRosterLoad;
		
		// load own vcard
		vcard = new jabber.client.VCardTemp( stream );
		vcard.onLoad = function(node,vc) {
			if( node == null )
				trace( "VCard loaded." );
			else
				trace( "VCard from "+node+" loaded." );
		};
		vcard.load();
	}
	
	static function handleRosterLoad() {
		trace( "Roster loaded:" );
		for( i in roster.items )
			trace( "\t"+i.jid );
	}
	
	static function handleDiscoInfo( node : String, info : xmpp.disco.Info ) {
		trace( "Service info result: "+node );
		trace( "\tIdentities: ");
		for( identity in info.identities )
			trace( "\t\t"+identity );
		trace( "\tFeatures: ");
		for( feature in info.features )
			trace( "\t\t"+feature );
	}
	
	static function handleDiscoItems( node : String, info : xmpp.disco.Items ) {
		trace( "Service items result: "+node );
	}
	
}
