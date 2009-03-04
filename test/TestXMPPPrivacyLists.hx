
/**
	Testunit for xmpp.PrivacyLists
*/
class TestXMPPPrivacyLists extends haxe.unit.TestCase {
	
	public function testParsing() {
		
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
		var list = lists.list[0];
		
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
	
	/* TODO
	public function testCreation() {
			
		var nlist = new xmpp.PrivacyList( "mylist" );
		nlist.items.push( new xmpp.privacylist.Item( xmpp.privacylist.Action.deny,
											   		 xmpp.privacylist.ItemType.jid,
											   		 "account@disktree",
											   		 77 ) );
		var l = new xmpp.PrivacyLists();
		l.list.push( nlist );
	}
	*/
	
} 
