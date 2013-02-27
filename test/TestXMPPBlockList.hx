
/**
	Testunit for xmpp.BlockList
*/
class TestXMPPBlockList extends haxe.unit.TestCase {
	
	public function testParse() {
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
	
	public function testBuild() {
		var x = new xmpp.BlockList( ["romeo@montague.net","iago@shakespeare.lit"] ).toXml();
		var _items = new Array<String>();
		for( e in x.elements() )
			_items.push( e.get("jid") );
		assertEquals( "romeo@montague.net", _items[0] );
		assertEquals( "iago@shakespeare.lit", _items[1] );
	}
	
}
