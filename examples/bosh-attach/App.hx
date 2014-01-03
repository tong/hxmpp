
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
	Stores a BOSH session into browser localStorage for re-load and re-attach on another site.
	The timeout for re-attaching is the BOSH connection timeout of the XMPP stream.
 */
@:require(js)
class App {
	
	static inline var LOCAL_STORAGE_ID = "xmpp-session";
	
	static var creds = XMPPClient.readArguments();
	static var storage = window.localStorage;
	static var cnx : BOSHConnection;
	static var stream : Stream;
	
	static function createXMPPStream() {
		cnx = new BOSHConnection( creds.ip, creds.http );
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
		stream.open( creds.jid );
	}
	
	static function onStreamClose( ?e ) {
		trace( 'XMPP stream closed: $e' );
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
		window.onload = function(_) {
			var cache = storage.getItem( LOCAL_STORAGE_ID );
			if( cache == null ) {
				createXMPPStream();
			} else {
				var now = Date.now().getTime();
				var d = Json.parse( cache );
				if( ( now - d.ts ) > 30000 ) {
					trace( "XMPP session timeout "+(Date.now().getTime() - d.ts));
					createXMPPStream();
					return;
				}
				trace( "Attaching active BOSH session ..." );
				trace( d );
				var jid = new JID( creds.jid );
				cnx = new BOSHConnection( creds.ip, creds.http );
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
	
}		
