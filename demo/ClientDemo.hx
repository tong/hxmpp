
import event.Dispatcher;
import jabber.JID;
import jabber.client.Roster;

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
		stream.open();
	}
	
}



/**
	Custom jabber stream providing basic IM functionality.
*/
private class Jabber extends jabber.client.Stream {
	
	public var onMessage(default,null) : Dispatcher<xmpp.Message>;
	public var onChatMessage(default,null) : Dispatcher<xmpp.Message>;
	//public var onRosterUpdate(default,null) : Dispatcher<jabber.client.Roster>;
	
	public var roster : Roster;
	
	
	var password : String;
	
	
	public function new( jid : JID, password : String, ?manualHost : String, ?manualPort : Int ) {
		
	//	#if ( js && !JABBER_SOCKETBRIDGE )
	//	connection = new jabber.StreamBOSHConnection( manualHost == null ? jid.domain : manualHost, manualPort == null ? jabber.client.Stream.DEFAULT_PORT : manualPort );
	//	#else
		connection = new jabber.StreamSocketConnection( manualHost == null ? jid.domain : manualHost, manualPort == null ? jabber.client.Stream.DEFAULT_PORT : manualPort );
	//	#end
		
		super( jid, connection, "1.0" );
		this.lang = "en";
		this.password = password;
		
		onOpen.addHandler( onStreamOpen );
		onClose.addHandler( onStreamClose );
		
	//	roster = new Roster( this );
	}
	
	
	override function onDisconnect() {
		trace( "DISCONNECTED from: " + jid.domain );
	}
	override function onData( data : String ) {
		trace( "XMPP IN:\n" + data, false );
		super.onData( data );
	}
	override public function sendData( data : String ) : Bool {
		trace( "XMPP OUT:\n" + data, true );
		return super.sendData( data );
	}
	
	
	function onStreamOpen( stream ) {
		
		trace( "STREAM OPENED" );
		
		var auth = new jabber.client.NonSASLAuthentication( this );
		auth.onSuccess.addHandler( onAuthenticated );
		auth.onFailed.addHandler( function(e) { trace( "Authentication failed!" ); } );
		auth.authenticate( password, "hxjab" );
	}
	
	function onStreamClose( stream ) {
		trace( "STREAM CLOSED" );
	}
	
	function onStreamError( stream ) {
		trace( "STREAM ERROR" );
	}
	
	function onAuthenticated( stream ) {
		trace( "STREAM AUTHENTICATED" );
		
	}
	
}
