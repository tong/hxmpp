
import jabber.client.Roster;
import jabber.client.RosterSubscriptionMode;

class App extends XMPPClient {
	
	public var roster(default,null) : Roster;
	
	override function onLogin() {
		roster = new Roster( stream, RosterSubscriptionMode.manual );
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
		trace( 'Roster ERROR : '+e );
	}
	
	function onRosterLoad() {
		trace( 'Roster loaded' );
		stream.sendPresence();
		//roster.subscribe( "julia@disktree" );
		//roster.unsubscribe( "julia@disktree", false );
		//roster.cancelSubscription( "julia@disktree" );
	}
	
	function onRosterItemAdded( item : xmpp.roster.Item ) {
		trace( 'Roster item added ($item)' );
	}
	
	function onRosterItemRemoved( item : xmpp.roster.Item ) {
		trace( 'Roster item removed ($item)');
	}
	
	function onSubscriptionAsk( i : xmpp.roster.Item ) {
		trace( i.jid+' wants to subscribe to your presence' );
	}
	
	function onSubscription( jid : String ) {
		trace( 'Roster subscription '+jid );
	}
	
	function onSubscribed( item : xmpp.roster.Item ) {
		trace( "Roster subscribed : "+item );
	}
	
	function onUnsubscribed( item : xmpp.roster.Item ) {
		trace( "Roster unsubscribed "+item.jid );
	}
	
	override function onPresence( p : xmpp.Presence ) {
		var jid = new jabber.JID( p.from );
		if( jid.bare == stream.jid.bare )
			return;
	}
	
	static function main() {
		var creds = XMPPClient.readArguments();
		new App( creds.jid, creds.password, creds.ip, creds.http ).login();
	}
	
}
