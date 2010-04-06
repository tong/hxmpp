
import jabber.SocketConnection;
import jabber.ServiceDiscovery;
import jabber.client.NonSASLAuth;
import jabber.client.Stream;
import jabber.client.Roster;
import jabber.client.VCard;

/**
	Basic jabber client.
*/
class ClientDemo {
	
	static inline var RESOURCE = #if neko "NEKO" #elseif flash "FLASH" #elseif js "JS" #elseif php "PHP" #elseif cpp "CPP" #end;
	
	static var jid = "hxmpp@disktree";
	static var password = "test";
	static var ip = "127.0.0.1";
	
	static var stream : Stream;
	static var roster : Roster;
	static var disco : ServiceDiscovery;
	static var vcard : VCard;
	
	static function init() {
		var jid = new jabber.JID( ClientDemo.jid );
#if js
	#if JABBER_SOCKETBRIDGE
		var cnx = new SocketConnection( ip, Stream.defaultPort );
	#else
		var cnx = new jabber.BOSHConnection( jid.domain, ip+"/http" );
	#end
#else
		var cnx = new SocketConnection( ip, 5222 );
#end
		stream = new Stream( jid, cnx );
		stream.onClose = function(?e) { trace( "Stream to: "+stream.jid.domain+" closed." ); } ;
		stream.onOpen = function() {
			trace( "XMPP stream to "+stream.jid.domain+" opened" );
			/*
			var auth = new NonSASLAuth( stream );
			auth.onSuccess = handleLogin;
			auth.onFail = function(?e) {
				trace( "Login failed "+e.name );
			};
			*/
			var mechanisms = new Array<jabber.sasl.TMechanism>();
			//mechanisms.push( new net.sasl.PlainMechanism() );
			mechanisms.push( new jabber.sasl.MD5Mechanism() );
			var auth = new jabber.client.SASLAuth( stream, mechanisms );
			auth.onSuccess = handleLogin;
			auth.onFail = function(?e) {
				trace( "Authentication failed", "warn" );
			};
			auth.authenticate( password, RESOURCE );
		};
		trace( "Initializing XMPP stream ..." );
		stream.open();
	}
	
	static function handleLogin() {

		trace( "Logged in as "+ stream.jid.node+" at "+stream.jid.domain );
		
		// load server disco infos
		disco = new ServiceDiscovery( stream );
		disco.onInfo = handleDiscoInfo;
		disco.onItems = handleDiscoItems;
		disco.items( stream.jid.domain );
		disco.info( stream.jid.domain );
		
		// load roster
		roster = new jabber.client.Roster( stream );
		roster.presence.change( null, "online" );
		roster.load();
		roster.onLoad = handleRosterLoad;
		
		// load own vcard
		vcard = new jabber.client.VCard( stream );
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
		for( i in roster.items ) {
			trace( "\t"+i.jid );
			
		}
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
	
	static function main() {
		#if flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		#if JABBER_SOCKETBRIDGE
		jabber.SocketBridgeConnection.initDelayed( "f9bridge", init );
		#else
		init();
		#end
	}
	
}
