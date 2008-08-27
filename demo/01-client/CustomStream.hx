
import jabber.JID;
import jabber.client.MessageListener;
import jabber.client.NonSASLAuthentication;
import jabber.client.Roster;
import jabber.client.ServiceDiscovery;
import jabber.client.VCardTemp;



class CustomStream extends jabber.client.Stream {
	
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
		
		var me = this;
		
		auth = new jabber.client.NonSASLAuthentication( this );
		auth.onSuccess.addHandler( authenticationSuccessHandler );
		auth.onFailed.addHandler( function(e) { trace( "Authentication failed!" ); } );
		
		messages = new MessageListener( this );
		messages.addHandler( messageHandler );
		
		roster = new Roster( this );
		roster.onAvailable.addHandler( rosterAvailableHandler );
		roster.onUpdate.addHandler( rosterUpdateHandler );
		roster.onRemove.addHandler( rosterRemoveHandler );
		roster.onPresence.addHandler( rosterPresenceHandler );
		
		vcard = new VCardTemp( this );
		vcard.onLoad.addHandler( vcardLoadHandler );
		
		onOpen.addHandler( function(s) {
			me.auth.authenticate( password, "hxjab" );
		} );
		onError.addHandler( function(e) {
			trace( "XMPP stream error: " + e.error.condition );
		} );
		onClose.addHandler( function(s) {
			trace( "Jabber stream to: "+jid.domain+" closed." );
		} );
		onXMPP.addHandler( function(xmpp) {
			trace( if( xmpp.incoming ) {
				"XMPP <<< " + xmpp.packet;
			} else {
				"XMPP >>> " + xmpp.packet;
			} );
		} );
	}
	
	
	function streamErrorHandler( stream ) {
		trace( "STREAM ERROR" );
	}
	
	function authenticationSuccessHandler( stream ) {
		roster.load();
		//vcard.load();
		
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
		trace( "VCard loaded: " + vc.from );
	}
	
	function vcardUpdatedHandler( vc : VCardChange ) {
		trace( "Vcard updated " + vc );
	}
	
	function rosterAvailableHandler( r : Roster ) {
		trace( "# Roster available, " + r.entries.length + " items"  );
		for( entry in r.entries ) {
			trace( "### " + entry.jid + " // " + entry.subscription  );
		}
	//	roster.subscribe("account@disktree");
	//	roster.unsubscribe( "account@disktree" );
	//	roster.remove( "account@disktree" );
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
