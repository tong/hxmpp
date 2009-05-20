
/**
	Testunit for xmpp.BlockList
*/
class TestXMPPBlockList extends haxe.unit.TestCase {
	
	public function testParsing() {
		
		var x =Xml.parse( "
<blocklist xmlns='urn:xmpp:blocking'>
    <item jid='romeo@montague.net'/>
    <item jid='iago@shakespeare.lit'/>
</blocklist>" ).firstElement();
		
		var l = xmpp.BlockList.parse( x );
		assertEquals( l.items.length, 2 );
		assertEquals( l.items[0], "romeo@montague.net" );
		assertEquals( l.items[1], "iago@shakespeare.lit" );
	}
	
}
