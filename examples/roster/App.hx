
import jabber.client.Roster;
import jabber.client.RosterSubscriptionMode;

class App extends XMPPClient {
	
	public var roster(default,null) : Roster;
	
	override function onLogin() {
		//roster = new Roster( stream, RosterSubscriptionMode.acceptAll(true) );
		//roster = new Roster( stream, RosterSubscriptionMode.manual );
		roster = new Roster( stream, RosterSubscriptionMode.rejectAll );
		roster.onError = onRosterError;
		roster.onLoad = onRosterLoad;
		roster.onAdd = onRosterItemAdded;
		roster.onRemove = onRosterItemRemoved;
		roster.onSubscribed = onSubscribed;
		roster.onSubscription = onSubscription;
		roster.onUnsubscribed = onUnsubscribed;
		roster.onAsk = onSubscriptionAsk;
		roster.load();
	}
	
	function onRosterError( e : jabber.XMPPError ) {
		trace( e );
	}
	
	function onRosterLoad() {
		trace("ROSTERTEST: onRosterLoad");
		new jabber.PresenceListener( stream, onPresence );
		stream.sendPresence();
		//roster.subscribe( "julia@disktree" );
		//roster.unsubscribe( "julia@disktree", false );
		//roster.cancelSubscription( "julia@disktree" );
	}
	
	function onRosterItemAdded( item : xmpp.roster.Item ) {
		trace("ROSTERTEST: onRosterItemAdded");
	}
	
	function onRosterItemRemoved( item : xmpp.roster.Item ) {
		trace("ROSTERTEST: onRosterItemRemoved");
	}
	
	function onSubscriptionAsk( i : xmpp.roster.Item ) {
		trace( i.jid+" wants to subscribe to your presence" );
	}
	
	function onSubscription( jid : String ) {
		trace("ROSTERTEST: onSubscription "+jid);
	}
	
	function onSubscribed( item : xmpp.roster.Item ) {
		trace("ROSTERTEST: onSubscribed");
	}
	
	function onUnsubscribed( item : xmpp.roster.Item ) {
		trace("ROSTERTEST: onUnsubscribed "+item.jid);
	}
	
	function onPresence( p : xmpp.Presence ) {
		var jid = new jabber.JID( p.from );
		if( jid.bare == stream.jid.bare )
			return;
	}
	
	static function main() {
		new App().login();
	}
	
}
