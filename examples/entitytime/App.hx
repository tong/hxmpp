
class App extends XMPPClient {
	
	var entity : String;
	
	override function onLogin() {
		new jabber.EntityTimeListener( stream );
		new jabber.PresenceListener( stream, onPresence );
		stream.sendPresence();
	}
	
	function onPresence( p : xmpp.Presence ) {
		if( p.from == entity && p.type == null ) {
			var etime = new jabber.EntityTime( stream );
			etime.onLoad = function(jid:String,t:xmpp.EntityTime) {
				trace( "Entity time: "+jid+": "+t.utc+" ("+t.tzo+")" );
			}
			etime.load( entity );
		}
	}
	
}
