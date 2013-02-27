
import xmpp.roster.Item;
import xmpp.roster.Subscription;
import xmpp.roster.AskType;

class TestXMPPRoster extends haxe.unit.TestCase {
	
	public function testParse() {
		var r = xmpp.Roster.parse( Xml.parse(
'<query xmlns="jabber:iq:roster">
	<item jid="test@disktree.net" name="Romeo" subscription="none" ask="subscribe"><group>Friends</group></item>
	<item jid="account@disktree.net" subscription="both"/>
</query>' ).firstElement() );
		
		var items = Lambda.array( xmpp.Roster.parse( r.toXml() ) );
		assertEquals( "test@disktree.net", items[0].jid );
		assertEquals( xmpp.roster.Subscription.none, items[0].subscription );
		assertEquals( xmpp.roster.AskType.subscribe, items[0].askType );
		assertEquals( "Romeo", items[0].name );
		assertEquals( "Friends", items[0].groups.first() );
		assertEquals( "account@disktree.net", items[1].jid );
		assertEquals( xmpp.roster.Subscription.both, items[1].subscription );
		
		//assertTrue(false);
	}
	
	public function testBuild() {
		var item = new Item( "test@disktree.net", Subscription.none, "test", AskType.subscribe, ["buddies"] );
		var x = item.toXml();
		assertEquals( "test@disktree.net", x.get("jid") );
		assertEquals( "none", x.get("subscription") );
		assertEquals( "subscribe", x.get("ask") );
		assertEquals( "buddies", x.firstChild().firstChild().toString() );
	}
	
}
