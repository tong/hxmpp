

class TestXMPPIQExtensions {}
	


/**
	Testunit for xmpp.Auth
*/
class TestAuthExtension extends haxe.unit.TestCase {
	
	public function testParsing() {
		
		var iq = xmpp.IQ.parse( Xml.parse( '<iq id="A8Q8u1" type="get"><query xmlns="jabber:iq:auth"><username>hxmpp</username></query></iq>' ).firstElement() );
		var auth = xmpp.Auth.parse( iq.ext.toXml() );
		assertEquals( auth.username, 'hxmpp' );
		assertEquals( auth.password, null );
		assertEquals( auth.resource, null );
		assertEquals( auth.digest, null );
		
		iq = xmpp.IQ.parse( Xml.parse(
		'<iq type="set" id="66ceE3">
			<query xmlns="jabber:iq:auth">
				<username>tong</username>
				<password>test</password>
				<resource>norc</resource>
				<digest>123</digest>
			</query>
		</iq>' ).firstElement() );
		auth = xmpp.Auth.parse( iq.ext.toXml() );
		assertEquals( auth.username, 'tong' );
		assertEquals( auth.password, 'test' );
		assertEquals( auth.resource, 'norc' );
		assertEquals( auth.digest, "123" );
	}
	
	public function testCreation() {
		var a = new xmpp.Auth( "tong", "test", "123", "hxmpp" );
		assertEquals( a.username, "tong" );
		assertEquals( a.password, "test" );
		assertEquals( a.digest, "123" );
		assertEquals( a.resource, "hxmpp" );
	}
}



/**
	Testunit for xmpp.Register
*/
class TestRegisterExtension extends haxe.unit.TestCase {
	
	public function testParsing() {
		var iq = xmpp.IQ.parse( Xml.parse(
		"<iq type='result' id='reg1'>
			<query xmlns='jabber:iq:register'>
   				<registered/>
				<username>juliet</username>
   				<password>R0m30</password>
				<email>juliet@capulet.com</email>
			</query>
		</iq>" ).firstElement() );
		var r = xmpp.Register.parse( iq.ext.toXml() );
		assertEquals( r.username, 'juliet' );
		assertEquals( r.password, 'R0m30' );
		assertEquals( r.email, 'juliet@capulet.com' );
		assertEquals( r.name, null );
	}
	
	public function testCreation() {
		var r = new xmpp.Register( "tong", "test", "mail@domain.com", "myname" );
		assertEquals( r.username, "tong" );
		assertEquals( r.password, "test" );
		assertEquals( r.email, "mail@domain.com" );
		assertEquals( r.name, "myname" );
	}
}



/**
	Testunit for xmpp.Roster
*/
class TestRosterExtension extends haxe.unit.TestCase {
	
	public function testParsing() {
		var r = xmpp.Roster.parse( Xml.parse(
		'<query xmlns="jabber:iq:roster">
			<item jid="test@disktree.net" subscription="both"/>
			<item jid="account@disktree.net" subscription="both"/>
		</query>' ).firstElement() );
		var items = Lambda.array( xmpp.Roster.parse( r.toXml() ) );
		assertEquals( "test@disktree.net", items[0].jid );
		assertEquals( "account@disktree.net", items[1].jid );

		//.
	}
	
	//..
}



/**
	Testunit for xmpp.disco.Info
*/
class TestDiscoExtension extends haxe.unit.TestCase {
	
	public function testParsingInfo() {
	
		var iq = xmpp.IQ.parse( Xml.parse( '
			<iq from="account@disktree.net" type="result" id="UkxsZUQz" to="tong@disktree.net/norc">
				<query xmlns="http://jabber.org/protocol/disco#info">
					<identity type="registered" category="account"/>
					<identity type="pep" category="pubsub"/>
					<feature var="http://jabber.org/protocol/disco#info"/>
				</query>
			</iq>').firstElement() );
		var info = xmpp.disco.Info.parse( iq.ext.toXml() );
		
		assertEquals( "registered", info.identities[0].type );
		assertEquals( "account", info.identities[0].category );
		assertEquals( null, info.identities[0].name );
		assertEquals( "pep", info.identities[1].type );
		assertEquals( "pubsub", info.identities[1].category );
		assertEquals( null, info.identities[1].name );
		assertEquals( "http://jabber.org/protocol/disco#info", info.features[0] );
	}
	
	public function testInfoCreation() {
		var x = new xmpp.disco.Info().toXml();
		assertEquals( xmpp.disco.Info.XMLNS, x.get( "xmlns" ) );
		//..
	}
		
	public function testParsingItems() {
		
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
		
		var items = xmpp.disco.Items.parse( iq.ext.toXml() );
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
	
	/*
	public function testItemsCreation() {
		var x = new xmpp.disco.Info().toXml();
		assertEquals( xmpp.disco.Info.XMLNS, x.get( "xmlns" ) );
		//..
	}
	*/
}



/**
	Testunit for xmpp.DataForm
*/
class TestDataFormExtension extends haxe.unit.TestCase {
	
	public function testParsing() {
		
		// example src from http://xmpp.org/extensions/xep-0004.html
		var form = xmpp.DataForm.parse( Xml.parse(
		"<x xmlns='jabber:x:data' type='form'>
      		<title>Bot Configuration</title>
      		<instructions>Fill out this form to configure your new bot!</instructions>
		    <field type='hidden' var='FORM_TYPE'><value>jabber:bot</value></field>
		    <field type='fixed'><value>Section 1: Bot Info</value></field>
		    <field type='text-single' label='The name of your bot' var='botname'/>
		    <field type='text-multi' label='Helpful description of your bot' var='description'/>
		    <field type='boolean' label='Public bot?' var='public'><required/></field>
		    <field type='text-private' label='Password for special access' var='password'/>
			<field type='fixed'><value>Section 2: Features</value></field>
		    <field type='list-multi' label='What features will the bot support?' var='features'>
				<option label='Contests'><value>contests</value></option>
		        <option label='News'><value>news</value></option>
		        <option label='Polls'><value>polls</value></option>
		        <option label='Reminders'><value>reminders</value></option>
		        <option label='Search'><value>search</value></option>
		        <value>news</value>
		        <value>search</value>
			</field>
		    <field type='fixed'><value>Section 3: Subscriber List</value></field>
		    <field type='list-single' label='Maximum number of subscribers' var='maxsubs'>
		        <value>20</value>
		        <option label='10'><value>10</value></option>
		        <option label='20'><value>20</value></option>
		        <option label='30'><value>30</value></option>
		        <option label='50'><value>50</value></option>
		        <option label='100'><value>100</value></option>
		        <option label='None'><value>none</value></option>
		    </field>
		    <field type='fixed'><value>Section 4: Invitations</value></field>
		    <field type='jid-multi' label='People to invite' var='invitelist'>
				<desc>Tell all your friends about your new bot!</desc>
			</field>
			</x>" ).firstElement() );

		assertEquals( 'Bot Configuration', form.title );
		assertEquals( 'Fill out this form to configure your new bot!', form.instructions );
		assertEquals( xmpp.dataform.FieldType.hidden, form.fields[0].type );
		assertEquals( 'FORM_TYPE', form.fields[0].variable );
		assertEquals( 'jabber:bot', form.fields[0].values[0] );
		
		assertEquals( xmpp.dataform.FieldType.fixed, form.fields[1].type );
		assertEquals( 'Section 1: Bot Info', form.fields[1].values[0] );
		
		assertEquals( xmpp.dataform.FieldType.text_single, form.fields[2].type );
		assertEquals( 'botname', form.fields[2].variable );
		assertEquals( 'The name of your bot', form.fields[2].label );
		
		assertEquals( xmpp.dataform.FieldType.text_multi, form.fields[3].type );
		assertEquals( 'Helpful description of your bot', form.fields[3].label );
		assertEquals( 'description', form.fields[3].variable );
		
		assertEquals( xmpp.dataform.FieldType.boolean, form.fields[4].type );
		assertEquals( 'Public bot?', form.fields[4].label );
		assertEquals( 'public', form.fields[4].variable );
		
		assertEquals( xmpp.dataform.FieldType.text_private, form.fields[5].type );
		assertEquals( 'Password for special access', form.fields[5].label );
		assertEquals( 'password', form.fields[5].variable );
		
		assertEquals( xmpp.dataform.FieldType.fixed, form.fields[6].type );
		assertEquals( 'Section 2: Features', form.fields[6].values[0] );
		
		assertEquals( xmpp.dataform.FieldType.list_multi, form.fields[7].type );
		assertEquals( 'What features will the bot support?', form.fields[7].label );
		assertEquals( 'features', form.fields[7].variable );
		assertEquals( 'Contests', form.fields[7].options[0].label );
		assertEquals( 'contests', form.fields[7].options[0].value );
		assertEquals( 'News', form.fields[7].options[1].label );
		assertEquals( 'news', form.fields[7].options[1].value );
		assertEquals( 'Polls', form.fields[7].options[2].label );
		assertEquals( 'polls', form.fields[7].options[2].value );
		assertEquals( 'Reminders', form.fields[7].options[3].label );
		assertEquals( 'reminders', form.fields[7].options[3].value );
		assertEquals( 'Search', form.fields[7].options[4].label );
		assertEquals( 'search', form.fields[7].options[4].value );
		assertEquals( 'news', form.fields[7].values[0] );
		assertEquals( 'search', form.fields[7].values[1] );
		
		assertEquals( xmpp.dataform.FieldType.fixed, form.fields[8].type );
		assertEquals( 'Section 3: Subscriber List', form.fields[8].values[0] );
		
		assertEquals( xmpp.dataform.FieldType.list_single, form.fields[9].type );
		assertEquals( 'Maximum number of subscribers', form.fields[9].label );
		assertEquals( 'maxsubs', form.fields[9].variable );
		assertEquals( '20', form.fields[9].values[0] );
		assertEquals( '10', form.fields[9].options[0].label );
		assertEquals( '10', form.fields[9].options[0].value );
		assertEquals( '20', form.fields[9].options[1].label );
		assertEquals( '20', form.fields[9].options[1].value );
		assertEquals( '30', form.fields[9].options[2].label );
		assertEquals( '30', form.fields[9].options[2].value );
		assertEquals( '50', form.fields[9].options[3].label );
		assertEquals( '50', form.fields[9].options[3].value );
		assertEquals( '100', form.fields[9].options[4].label );
		assertEquals( '100', form.fields[9].options[4].value );
		assertEquals( 'None', form.fields[9].options[5].label );
		assertEquals( 'none', form.fields[9].options[5].value );
		
		assertEquals( xmpp.dataform.FieldType.fixed, form.fields[10].type );
		assertEquals( 'Section 4: Invitations', form.fields[10].values[0] );
		
		assertEquals( xmpp.dataform.FieldType.jid_multi, form.fields[11].type );
		assertEquals( 'People to invite', form.fields[11].label );
		assertEquals( 'invitelist', form.fields[11].variable );
		assertEquals( 'Tell all your friends about your new bot!', form.fields[11].desc );
	}
	
	/*
	public function test() {
		TODO test with example which include ALL elements!
	}
	*/
}



/**
	Testunit for xmpp.DelayedDelivery
*/
class TestDelayedDeliveryExtension extends haxe.unit.TestCase {
	
	public function testParsing() {
		
		var m = xmpp.Message.parse( Xml.parse( "
		<message from='romeo@montague.net/orchard' to='juliet@capulet.com' type='chat'>
			<body>O blessed, blessed night! I am afeard. Being in night, all this is but a dream, Too flattering-sweet to be substantial.</body>
			<delay xmlns='urn:xmpp:delay' from='capulet.com' stamp='2002-09-10T23:08:25Z'>Offline Storage</delay>
		</message>" ).firstElement() );
		var delay = xmpp.Delayed.get( m );
		assertEquals( delay.from, 'capulet.com' );
		assertEquals( delay.stamp, '2002-09-10T23:08:25Z' );
		assertEquals( delay.description, 'Offline Storage' );
		
		var p = xmpp.Presence.parse( Xml.parse( "
		<presence from='juliet@capulet.com/balcony' to='romeo@montague.net'>
			<status>anon!</status>
			<show>xa</show>
			<priority>1</priority>
			<delay xmlns='urn:xmpp:delay' from='juliet@capulet.com/balcony' stamp='2002-09-10T23:41:07Z'/>
		</presence>
		" ).firstElement() );
		delay = xmpp.Delayed.get(p );
		assertEquals( delay.from, 'juliet@capulet.com/balcony' );
		assertEquals( delay.stamp, '2002-09-10T23:41:07Z' );
		assertEquals( delay.description, null );
	}
}


/**
	Testunit for xmpp.ChatStatePacket
*/
class TestChatStateExtension extends haxe.unit.TestCase {
	
	public function testParsing() {
		
		var m = xmpp.Message.parse( Xml.parse( "
		<message from='bernardo@shakespeare.lit/pda' to='francisco@shakespeare.lit' type='chat'>
			<body>Who's there?</body>
		</message>" ).firstElement() );
		assertEquals( null, xmpp.ChatStateExtension.get( m ) );

		m = xmpp.Message.parse( Xml.parse( "
		<message from='bernardo@shakespeare.lit/pda' to='francisco@shakespeare.lit' type='chat'>
			<body>Who's there?</body>
			<active xmlns='http://jabber.org/protocol/chatstates'/>
		</message>" ).firstElement() );
		assertEquals( xmpp.ChatState.active, xmpp.ChatStateExtension.get( m ) );
		
		m = xmpp.Message.parse( Xml.parse( "
		<message from='bernardo@shakespeare.lit/pda' to='francisco@shakespeare.lit' type='chat'>
			<body>Who's there?</body>
			<composing xmlns='http://jabber.org/protocol/chatstates'/>
		</message>" ).firstElement() );
		assertEquals( xmpp.ChatState.composing, xmpp.ChatStateExtension.get( m ) );
		
		m = xmpp.Message.parse( Xml.parse( "
		<message from='bernardo@shakespeare.lit/pda' to='francisco@shakespeare.lit' type='chat'>
			<body>Who's there?</body>
		</message>" ).firstElement() );
		xmpp.ChatStateExtension.set( m, xmpp.ChatState.composing );
		assertEquals( xmpp.ChatState.composing, xmpp.ChatStateExtension.get( m ) );
	}
}



/**
	Testunit for xmpp.LastActivity
*/
class TestLastActivityExtension extends haxe.unit.TestCase {
	
	public function testParsing() {
		var q = Xml.parse( "<query xmlns='jabber:iq:last' seconds='903'/>" ).firstElement();
		var activity = xmpp.LastActivity.parse( q );
		var secs = xmpp.LastActivity.parseSeconds( q );
		assertEquals( 903, activity.seconds );
		assertEquals( 903, secs );
	}
}



/**
	Testunit for xmpp.PrivacyLists
*/
class TestPrivacyListsExtension extends haxe.unit.TestCase {
	
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
