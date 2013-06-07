
using jabber.JIDUtil;

class App extends XMPPClient {
	
	var entity : String;

	override inline function getResource() : String return "hxmpp";

	override function onLogin() {
		new jabber.EntityTimeListener( stream );
		new jabber.PresenceListener( stream, onPresence );
		stream.sendPresence();
	}
	
	function onPresence( p : xmpp.Presence ) {
		if( p.from == entity && p.type == null ) {
			var time = new jabber.EntityTime( stream );
			time.onLoad = function(jid:String,t:xmpp.EntityTime) {
				trace( "Entity time: "+jid+": "+t.utc+" ("+t.tzo+")" );
			}
			time.load( entity );
		}
	}
	
}
