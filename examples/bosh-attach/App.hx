
import haxe.Json;
import jabber.JID;
import jabber.BOSHConnection;
import jabber.client.Stream;

#if js
import js.Browser;
import js.Browser.document;
import js.Browser.window;
#elseif flash
import flash.net.SharedObject;
#end

private typedef SessionState = {
	var timestamp : Float;
	var sid : String;
	var rid : Int;
	var wait : Int;
	var hold : Int;
}

private class SessionStore {

	static inline var ID = "jabber-session";
	
	public static function store( state : SessionState ) {
		#if js
		window.localStorage.setItem( ID, Json.stringify( state ) );
		#elseif flash
		var so = SharedObject.getLocal( ID );
		#end
	}

	public static function load() : SessionState {
		#if js
		var d = window.localStorage.getItem( ID );
		return (d == null) ? null : Json.parse(d);
		#elseif flash
		return SharedObject.getLocal( ID ).data;
		#end
	}

	public static function clear() {
		#if js
		window.localStorage.clear();
		#elseif flash
		 SharedObject.getLocal( ID ).clear();
		#end
	}
}

/**
	Stores a BOSH session into browser's localStorage for re-load and re-attach on another site.
	The timeout for re-attaching is the BOSH connection timeout of the XMPP stream.
*/
class App {

	static var TIMEOUT = 30;
	
	static var creds = XMPPClient.readArguments();
	static var cnx : BOSHConnection;
	static var stream : Stream;
	
	static function connect() {
		trace(creds);
		cnx = new BOSHConnection( creds.ip, creds.http, 2, TIMEOUT );
		stream = new jabber.client.Stream( cnx );
		stream.onOpen = function(){
			var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
			auth.onSuccess = function(){
				stream.sendPresence( null, #if js document.title #else "I am idiot flash" #end );
				saveState();
			}
			auth.onFail = function(e){
				trace( 'Authentication failed: (${stream.jid}' );
			}
			auth.start( creds.password, 'hxmpp' );
		}
		stream.onClose = onStreamClose;
		stream.open( creds.jid );
	}
	
	static function onStreamClose( ?e ) {
		trace( 'XMPP stream closed: $e' );
	}
	
	static function saveState() {
		SessionStore.store( {
			timestamp : Date.now().getTime(),
			sid : cnx.sid,
			rid : cnx.rid,
			wait : cnx.wait,
			hold : cnx.hold
		});
	}

	@:access(jabber.Stream)
	static function init() {
		var session = SessionStore.load();
		if( session == null ) {
			connect();
		} else {
			var now = Date.now().getTime();
			var elapsed = Date.now().getTime() - session.timestamp;
			if( elapsed > TIMEOUT ) {
				trace( "Session timeout" );
				trace( "Reconnecting ..." );
				connect();
			} else {
				
				trace( "Attaching session "+session );
				var jid = new JID( creds.jid );
				cnx = new BOSHConnection( creds.ip, creds.http );
				stream = new Stream( cnx );
				stream.onClose = onStreamClose;
				stream.jid = jid;
				stream.status = open;
				
				// Recreate connection
				cnx.attach( session.sid, session.rid, session.wait, session.hold );
				
				// Clear previously stored session
				SessionStore.clear();

				// Send initial presence
				stream.sendPresence( null, #if flash "I am flash, unga bunga" #else document.title #end );
			}
		}
	}

	static function onBeforeUnload(_) {
		if( stream != null && stream.status == open ) {
			saveState();
		} else {
			SessionStore.clear();
		}
	}

	static function main() {
		#if js
		window.onbeforeunload = onBeforeUnload;
		window.onload = function(_) { init(); };
		#elseif flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		init();
		#end
	}
	
}		
