
/**
	Testunit for xmpp.Roster
*/
class TestXMPPRoster extends haxe.unit.TestCase {
	
	public function testParsing() {
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
	}
	
}
