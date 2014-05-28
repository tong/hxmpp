
import XMPPClient;

/**
	Test/Example for requesting the local time of an entity using XEP-202
*/
class App extends XMPPClient {
	
	static inline var RESOURCE = 'hxmpp';

	override function onLogin() {
		
		trace("logged in");

		new jabber.PresenceListener( stream, function(p){
			
			if( p.type == null ) {
				
				// Request buddy time
				var time = new jabber.EntityTime( stream );
				time.onLoad = function(jid:String,time:xmpp.EntityTime) {
					var info = 'Entity time of $jid: ${time.utc}';
					if( time.tzo != null )
						info += ' TZ= ${time.tzo}';
					trace( info );
				}
				time.request( p.from );
			}
		});

		// Listen for entity time request from other entities
		var listener = new jabber.EntityTimeListener( stream );
		
		// Optionally specify a request callback to handle requests
		listener.onRequest = function(jid){
			trace( '$jid has requested my time' );
			return new xmpp.EntityTime( xmpp.DateTime.now().toString(), '23:00' );
		}

		// Send initial presence
		stream.sendPresence();
	}

	static function main() {
		var creds = XMPPClient.readArguments();
		new App( creds.jid, creds.password, creds.ip, creds.http ).login();
	}
	
}
