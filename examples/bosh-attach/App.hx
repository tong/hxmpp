
import haxe.Json;
import jabber.JID;
import jabber.BOSHConnection;
import jabber.StreamStatus;
import jabber.client.Stream;
import js.Browser;
import js.Browser.document;
import js.Browser.window;

private typedef SessionState = {
	ts : Float,
	sid : String,
	rid : Int,
	wait : Int,
	hold : Int
}

/**
	Stores a BOSH session into localStorage for re-load and re-attach on another website.
	The timeout for re-attaching is the BOSH connection timeout.
 */
class App {
	
	static inline var LOCAL_STORAGE_ID = "xmpp-session";
	
	static var storage = Browser.window.localStorage;

	static var creds = XMPPClient.getAccountFromFile();
	static var cnx : BOSHConnection;
	static var stream : Stream;
	
	static function createXMPPStream() {
		
		trace( "Initializing XMPP stream ..." );

		cnx = new BOSHConnection( creds.host, creds.http );
		stream = new jabber.client.Stream( cnx );
		stream.onOpen = function(){
			trace("XMPP stream opened");
			var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
			auth.onSuccess = function(){
				trace( "Authenticated as: "+stream.jid.s );
				stream.sendPresence( null, document.title );
				saveState();
			}
			auth.onFail = function(e){
				trace( "Authentication failed! ("+stream.jid.s+")" );
			}
			auth.start( creds.password, "hxmpp" );
		}
		stream.onClose = onStreamClose;
		stream.open( new jabber.JID( creds.user+"@"+creds.host ) );
	}
	
	static function onStreamClose( ?e ) {
		trace( "XMPP stream closed: "+e );
	}
	
	static function saveState() {
		var state : SessionState = {
			ts : Date.now().getTime(),
			sid : cnx.sid,
			rid : cnx.rid,
			wait : cnx.wait,
			hold : cnx.hold
		};
		storage.setItem( LOCAL_STORAGE_ID, Json.stringify( state ) );
		trace( "XMPP session state saved." );
	}
	
	static function onBeforeUnload(_) {
		if( stream.status == StreamStatus.open ) {
			saveState();
		} else {
			storage.clear();
		}
	}

	static function main() {
		var cache = storage.getItem( LOCAL_STORAGE_ID );
		if( cache == null ) {
			createXMPPStream();
		} else {
			var d = Json.parse( cache );
			if( ( Date.now().getTime() - d.ts ) > 30000 ) {
				trace( "TIMEOUT "+(Date.now().getTime() - d.ts));
				createXMPPStream();
				return;
			}
			trace( "Attaching active BOSH session ..." );
			trace( d );
			var jid = new JID( creds.user+"@"+creds.host );
			cnx = new BOSHConnection( creds.host, creds.http );
			stream = new Stream( cnx );
			stream.onClose = onStreamClose;
			stream.jid = jid;
			stream.status = StreamStatus.open;
			cnx.attach( d.sid, d.rid, d.wait, d.hold );
			new jabber.PresenceListener( stream, function(p) {
				stream.sendMessage( "julia@disktree.local", "Kiss!" );
			});
			storage.clear(); // clear previously saved session
			stream.sendPresence( null, document.title );
		}
		window.onbeforeunload = onBeforeUnload;
	}
	
}		
