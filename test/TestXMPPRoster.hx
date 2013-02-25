
import xmpp.roster.Item;
import xmpp.roster.Subscription;
import xmpp.roster.AskType;

class TestXMPPRoster extends TestCase {
	
	public function testParse() {
		var r = xmpp.Roster.parse( Xml.parse(
'<query xmlns="jabber:iq:roster">
	<item jid="test@disktree.net" name="Romeo" subscription="none" ask="subscribe"><group>Friends</group></item>
	<item jid="account@disktree.net" subscription="both"/>
</query>' ).firstElement() );
		
		var items = Lambda.array( xmpp.Roster.parse( r.toXml() ) );
		eq( "test@disktree.net", items[0].jid );
		eq( xmpp.roster.Subscription.none, items[0].subscription );
		eq( xmpp.roster.AskType.subscribe, items[0].askType );
		eq( "Romeo", items[0].name );
		eq( "Friends", items[0].groups.first() );
		eq( "account@disktree.net", items[1].jid );
		eq( xmpp.roster.Subscription.both, items[1].subscription );
		
		//assertTrue(false);
	}
	
	public function testBuild() {
		var item = new Item( "test@disktree.net", Subscription.none, "test", AskType.subscribe, ["buddies"] );
		var x = item.toXml();
		eq( "test@disktree.net", x.get("jid") );
		eq( "none", x.get("subscription") );
		eq( "subscribe", x.get("ask") );
		eq( "buddies", x.firstChild().firstChild().toString() );
	}
	
}
