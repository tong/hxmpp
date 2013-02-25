
class TestXMPPPrivacyLists extends TestCase {
	
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
		
		eq( "special", list.name );
		eq( 4, list.items.length );
		
		eq( xmpp.privacylist.ItemType.jid, list.items[0].type );
		eq( 'juliet@example.com', list.items[0].value );
		eq( xmpp.privacylist.Action.allow, list.items[0].action );
		eq( 6, list.items[0].order );
	
		eq( xmpp.privacylist.ItemType.jid, list.items[1].type );
		eq( 'benvolio@example.org', list.items[1].value );
		eq( xmpp.privacylist.Action.allow, list.items[1].action );
		eq( 7, list.items[1].order );
		
		eq( xmpp.privacylist.ItemType.jid, list.items[2].type );
		eq( 'mercutio@example.org', list.items[2].value );
		eq( xmpp.privacylist.Action.deny, list.items[2].action );
		eq( 42, list.items[2].order );
		
		eq( null, list.items[3].type );
		eq( null, list.items[3].value );
		eq( xmpp.privacylist.Action.deny, list.items[3].action );
		eq( 666, list.items[3].order );
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
				eq( xmpp.privacylist.Action.deny, l.items[0].action );
				eq( xmpp.privacylist.ItemType.jid, l.items[0].type );
				eq( "account@disktree", l.items[0].value );
				eq( 77, l.items[0].order );
			}
		}
	}
	
} 
