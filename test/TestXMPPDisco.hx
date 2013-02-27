
class TestXMPPDisco extends haxe.unit.TestCase {
	
	public function testParseInfo() {
		var iq = xmpp.IQ.parse( Xml.parse( '
			<iq from="account@disktree.net" type="result" id="UkxsZUQz" to="tong@disktree.net/norc">
				<query xmlns="http://jabber.org/protocol/disco#info">
					<identity type="registered" category="account"/>
					<identity type="pep" category="pubsub"/>
					<feature var="http://jabber.org/protocol/disco#info"/>
				</query>
			</iq>').firstElement() );
		var info = xmpp.disco.Info.parse( iq.x.toXml() );
		assertEquals( "registered", info.identities[0].type );
		assertEquals( "account", info.identities[0].category );
		assertEquals( null, info.identities[0].name );
		assertEquals( "pep", info.identities[1].type );
		assertEquals( "pubsub", info.identities[1].category );
		assertEquals( null, info.identities[1].name );
		assertEquals( "http://jabber.org/protocol/disco#info", info.features[0] );
	}
	
	public function testBuildInfo() {
		var x = new xmpp.disco.Info().toXml();
		assertEquals( xmpp.disco.Info.XMLNS, x.get( "xmlns" ) );
		//..TODO
	}
		
	public function testParseItems() {
	
		var x = new xmpp.disco.Item( "node@disktree.net" ).toXml();
		assertEquals( "item", x.nodeName );
		assertEquals( "node@disktree.net", x.get("jid") );
		
		var iq = xmpp.IQ.parse( Xml.parse('
			<iq from="disktree.net" type="result" id="eHJGKzYz" to="tong@disktree/norc">
			<query xmlns="http://jabber.org/protocol/disco#items">
				<item name="Public Chatrooms" jid="conference.disktree"/>
				<item name="Socks 5 Bytestreams Proxy" jid="proxy.disktree"/>
				<item name="User Search" jid="search.disktree"/>
				<item name="Publish-Subscribe service" jid="pubsub.disktree"/>
			</query>
		</iq>').firstElement() );
		var items = xmpp.disco.Items.parse( iq.x.toXml() );
		var results_name = [ "Public Chatrooms", "Socks 5 Bytestreams Proxy", "User Search", "Publish-Subscribe service" ];
		var results_jid = [ "conference.disktree", "proxy.disktree", "search.disktree", "pubsub.disktree" ];
		var results_node = [null,null,null,null];
		var i = 0;
		for( item in items ) {
			assertEquals( results_name[i], item.name );
			assertEquals( results_jid[i], item.jid );
			assertEquals( results_node[i], item.node );
			i++;
		}
	}
	
	public function testBuildItems() {
		var x = new xmpp.disco.Info().toXml();
		assertEquals( xmpp.disco.Info.XMLNS, x.get( "xmlns" ) );
		//..TODO
	}
	
}
