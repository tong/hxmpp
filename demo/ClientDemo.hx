
import event.Dispatcher;
import jabber.JID;
import jabber.client.MessageListener;
import jabber.client.NonSASLAuthentication;
import jabber.client.Roster;
import jabber.client.ServiceDiscovery;
import jabber.client.VCardTemp;

#if JABBER_SOCKETBRIDGE
import jabber.StreamSocketConnection;
#end


/**
	flash9, neko, js, php.
	
	Basic jabber client example.
*/
class ClientDemo {
	
	static function main() {
		
		jabber.tool.XMPPDebug.setRedirection();
		
		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		#if JABBER_SOCKETBRIDGE
		trace( "Using socket bridge for connecting to server." );
		jabber.SocketBridgeConnection.init( "f9bridge", init );
		
		#else
		init();

		#end
	}
	
	static function init() {
		trace( "initializing jabber client ..." );
		var acc = new jabber.util.ResourceAccount( "account" );
		var stream = new Jabber( new JID( acc.jid ), acc.password, acc.host, acc.port );
		try {
			stream.open();
		} catch( e : Dynamic ) {
			trace( "JABBER ERROR: " + e );
		}
	}
	
}



/**
	Custom jabber stream providing basic instant messaging functionality.
*/
private class Jabber extends jabber.client.Stream {
	
	//public var onMessage(default,null) : Dispatcher<xmpp.Message>;
	//public var onChatMessage(default,null) : Dispatcher<xmpp.Message>;
	//public var onRosterUpdate(default,null) : Dispatcher<jabber.client.Roster>;
	
	public var service(default,null) : ServiceDiscovery;
	public var roster(default,null) : Roster;
	public var auth(default,null) : NonSASLAuthentication;
	public var messages(default,null) : MessageListener;
	public var vcard : VCardTemp;
	
	var password : String;
	
	
	public function new( jid : JID, password : String, ?manualHost : String, ?manualPort : Int ) {
		
	//	#if ( js && !JABBER_SOCKETBRIDGE )
	//	connection = new jabber.StreamBOSHConnection( manualHost == null ? jid.domain : manualHost, manualPort == null ? jabber.client.Stream.DEFAULT_PORT : manualPort );
	//	#else
		connection = new jabber.StreamSocketConnection( manualHost == null ? jid.domain : manualHost,
														manualPort == null ? jabber.client.Stream.DEFAULT_PORT : manualPort );
	//	#end
		
		super( jid, connection, "1.0" );
		this.lang = "en";
		this.password = password;
		
		auth = new jabber.client.NonSASLAuthentication( this );
		auth.onSuccess.addHandler( authenticationSuccessHandler );
		auth.onFailed.addHandler( function(e) { trace( "Authentication failed!" ); } );
		
		messages = new MessageListener( this );
		messages.addHandler( messageHandler );
		
		roster = new Roster( this );
		roster.onAvailable.addHandler( rosterAvailableHandler );
		roster.onUpdate.addHandler( rosterUpdateHandler );
		roster.onUpdate.addHandler( rosterRemoveHandler );
		roster.onPresence.addHandler( rosterPresenceHandler );
		
		vcard = new VCardTemp( this );
		vcard.onLoad.addHandler( vcardLoadHandler );
		
		onOpen.addHandler( streamOpenHandler );
		onClose.addHandler( streamCloseHandler );
	}
	
	
	function streamOpenHandler( stream ) {
		auth.authenticate( password, "hxjab" );
	}
	
	function streamCloseHandler( stream ) {
		trace( "STREAM CLOSED" );
	}
	
	function streamErrorHandler( stream ) {
		trace( "STREAM ERROR" );
	}
	
	function authenticationSuccessHandler( stream ) {
		roster.load();
	//	vcard.load();
		
		if( Std.is( connection, jabber.StreamSocketConnection ) ) { 
			/*
			#if neko
			var keepAlive = new net.util.KeepAlive( 1000 );
			keepAlive.onPing.addHandler( function(p) { 
				//trace("-");
				//stream.sendData(p);
			} );
			keepAlive.start();
			#end
			*/
		}
	}
	
	function messageHandler( m : xmpp.Message ) {
		trace( "Recieved message from " + m.from + ": " + m.body );
	}
	
	function vcardLoadHandler( vc : VCardChange ) {
		trace( "VCard loaded: " + vc.data.fullName );
		/*
	//	trace( "VCard loaded: " + vc.data.nickName );
	//	vc.data.fullName = "herbert hutter";
		vc.data.nickName = "tong";
		vc.data.birthday = "1982-06-01";
	//	vc.data.email.pref = "tong@disktree.net";
		vc.data.url = "http://disktree.net";
		vcard.update( vc.data );
	*/
	}
	
	function vcardUpdatedHandler( vc : VCardChange ) {
		trace( "Vcard updated " + vc );
	}
	
	function rosterAvailableHandler( r : Roster ) {
		trace( "Roster loaded, " + r.entries.length + " items"  );
		roster.sendPresence( new xmpp.Presence( "available" ) );
	}
	
	function rosterUpdateHandler( e : List<RosterEntry> ) {
		trace( "Roster entries updated " + e.length );
	}
	
	function rosterRemoveHandler( e : List<RosterEntry> ) {
		trace( "Roster entries removed " + e.length );
	}
	
	function rosterPresenceHandler( e : RosterEntry ) {
		trace( "Presence from " + e.jid + ": " + e.presence.type  );
	}
	
}
