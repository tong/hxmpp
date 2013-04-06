
class TestXMPPPrivacyLists extends haxe.unit.TestCase {
	
	public function testParse() {
		
		var query = Xml.parse(
"<query xmlns='jabber:iq:privacy'>
  <list name='special'>
    <item type='jid'
          value='juliet@example.com'
          action='allow'
          order='6'/>
    <item type='jid'
          value='benvolio@example.org'
          action='allow'
          order='7'/>
    <item type='jid'
          value='mercutio@example.org'
          action='deny'
          order='42'/>
    <item action='deny' order='666'/>
  </list>
</query>
" ).firstElement();
		
		var lists = xmpp.PrivacyLists.parse( query );
		var list = lists.lists[0];
		
		assertEquals( "special", list.name );
		assertEquals( 4, list.items.length );
		
		assertEquals( xmpp.privacylist.ItemType.jid, list.items[0].type );
		assertEquals( 'juliet@example.com', list.items[0].value );
		assertEquals( xmpp.privacylist.Action.allow, list.items[0].action );
		assertEquals( 6, list.items[0].order );
	
		assertEquals( xmpp.privacylist.ItemType.jid, list.items[1].type );
		assertEquals( 'benvolio@example.org', list.items[1].value );
		assertEquals( xmpp.privacylist.Action.allow, list.items[1].action );
		assertEquals( 7, list.items[1].order );
		
		assertEquals( xmpp.privacylist.ItemType.jid, list.items[2].type );
		assertEquals( 'mercutio@example.org', list.items[2].value );
		assertEquals( xmpp.privacylist.Action.deny, list.items[2].action );
		assertEquals( 42, list.items[2].order );
		
		assertEquals( null, list.items[3].type );
		assertEquals( null, list.items[3].value );
		assertEquals( xmpp.privacylist.Action.deny, list.items[3].action );
		assertEquals( 666, list.items[3].order );
	}
	
	public function testBuild() {
		var nlist = new xmpp.PrivacyList( "mylist" );
		nlist.items.push( new xmpp.privacylist.Item( xmpp.privacylist.Action.deny,
											   		 xmpp.privacylist.ItemType.jid,
											   		 "account@disktree",
											   		 77 ) );
		var lists = new xmpp.PrivacyLists();
		lists.lists.push( nlist );
		var x = lists.toXml();
		for( l in lists ) {
			if( l.name == "mylist" ) {
				assertEquals( xmpp.privacylist.Action.deny, l.items[0].action );
				assertEquals( xmpp.privacylist.ItemType.jid, l.items[0].type );
				assertEquals( "account@disktree", l.items[0].value );
				assertEquals( 77, l.items[0].order );
			}
		}
	}
	
} 
