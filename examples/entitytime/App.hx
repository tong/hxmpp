
import XMPPClient;

/**
	Test/Example for requesting the local time of an entity using XEP-202
*/
class App extends XMPPClient {
	
	static inline var RESOURCE = 'hxmpp';

	var buddy : String;

	function new( creds : AccountCredentials, buddy : String ) {
		super( creds );
		this.buddy = buddy;
	}

	override inline function getResource() : String return RESOURCE;

	override function onLogin() {
		
		// Listen for buddy presence
		new jabber.PresenceListener( stream, function(p){
			if( p.from == buddy && p.type == null ) {
				
				// Request buddy time
				var etime = new jabber.EntityTime( stream );
				etime.onLoad = function(jid:String,time:xmpp.EntityTime) {
					var info = 'Entity time of $jid: ${time.utc}';
					if( time.tzo != null )
						info += ' TZ= ${time.tzo}';
					trace( info );
				}
				etime.load( buddy );
			}
		});

		// Listen for entity time request from other entities
		var elistener = new jabber.EntityTimeListener( stream );

		// Optionally specify a request callback to handle requests
		elistener.onRequest = function(jid){
			trace( '$jid has requested my time' );
			//if( jid == "any" )
			return new xmpp.EntityTime( xmpp.DateTime.now().toString(), '12:00' );
		}

		// Send initial presence
		stream.sendPresence();
	}

	static function main() {
		var account = XMPPClient.getAccountCredentials( #if account_a "romeo" #else "julia" #end );
		var buddy 	= XMPPClient.getAccountCredentials( #if account_a "julia" #else "romeo" #end );
		var app = new App(
			account,
			buddy.user+'@'+buddy.host+'/'+RESOURCE
		);
		app.login();
	}
	
}
