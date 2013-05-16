
class App extends XMPPClient {
	
	var lastActivityListener : jabber.LastActivityListener;
	
	override function onLogin() {
	
		super.onLogin();
		
		lastActivityListener = new jabber.LastActivityListener( stream );
		new jabber.PresenceListener( stream, onPresence );
		stream.sendPresence();
		
		var t = new jabber.util.Timer( 1000 );
		t.run = onTimer;
	}
	
	function onPresence( p : xmpp.Presence ) {
		var activity = new jabber.LastActivity( stream );
		activity.onLoad = function(e,secs) {
			trace( "Last activity of: "+e+": "+secs );
		};
		activity.onError = function(e){ trace(e); };
		activity.request( p.from );
	}
	
	function onTimer() {
		lastActivityListener.time++; // update own last activity time
	}
	
}
