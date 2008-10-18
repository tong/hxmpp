
import xmpp.Roster;
import xmpp.DataForm;



class TestXMPPIQExtensions {

	static function main() {
		
		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		haxe.Firebug.redirectTraces();
		
		var r = new haxe.unit.TestRunner();
		r.add( new TestAuthExtension() );
		r.add( new TestRosterExtension() );
		r.add( new TestDataFormExtension() );
		r.run();
	}
	
}



/**
	Testunit for xmpp.Auth
*/
class TestAuthExtension extends haxe.unit.TestCase {
	
	public function testAuthExt() {
		var iq = xmpp.IQ.parse( Xml.parse( '<iq type="set" id="66ceE3"><query xmlns="jabber:iq:auth"><username>tong</username><password>test</password><resource>norc</resource><digest>123</digest></query></iq>' ).firstElement() );
		var auth = xmpp.Auth.parse( iq.ext.toXml() );
		assertEquals( auth.username, 'tong' );
		assertEquals( auth.password, 'test' );
		assertEquals( auth.resource, 'norc' );
		assertEquals( auth.digest, "123" );
	}

}



/**
	Testunit for xmpp.Roster
*/
class TestRosterExtension extends haxe.unit.TestCase {
	
	public function testRosterExt() {
		//TODO
		/*
		var iq = xmpp.IQ.parse( Xml.parse( '<iq type="result" id="E/xud+7" to="tong@disktree/norc"><query xmlns="jabber:iq:roster"><item jid="test@disktree" subscription="both"/><item jid="account@disktree" subscription="both"/></query></iq>' ).firstElement() );
		var r = xmpp.Roster.parse( iq.ext.toXml() );
		
		for( item in r ) {
			assertEquals( "1","1");
		}
		*/
		assertEquals("1","1");
		/*
		var iq = new xmpp.IQ();
		var ext = new xmpp.RosterItem( "test@disktree.net" );
		iq.ext = ext;
		
		//trace( iq.toString() );
		//subscription="both" name="testnick"
		assertEquals( ext.toString(), '<item jid="test@disktree.net"/>' );
		assertEquals( iq.toString(), '<iq type="get" id="null"><item jid="test@disktree.net"/></iq>' );
	
	//	ext.name = "testnick";
	//	ext.subscription = xmpp.Subscription.both;
	//.........TODO
		*/
	}

}


/**
	Testunit for xmpp.DataForm
*/
class TestDataFormExtension extends haxe.unit.TestCase {
	
	public function testAuthExt() {
		
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
		assertEquals( DataFormFieldType.hidden, form.fields[0].type );
		assertEquals( 'FORM_TYPE', form.fields[0].variable );
		assertEquals( 'jabber:bot', form.fields[0].values[0] );
		
		assertEquals( DataFormFieldType.fixed, form.fields[1].type );
		assertEquals( 'Section 1: Bot Info', form.fields[1].values[0] );
		
		assertEquals( DataFormFieldType.text_single, form.fields[2].type );
		assertEquals( 'botname', form.fields[2].variable );
		assertEquals( 'The name of your bot', form.fields[2].label );
		
		assertEquals( DataFormFieldType.text_multi, form.fields[3].type );
		assertEquals( 'Helpful description of your bot', form.fields[3].label );
		assertEquals( 'description', form.fields[3].variable );
		
		assertEquals( DataFormFieldType.boolean, form.fields[4].type );
		assertEquals( 'Public bot?', form.fields[4].label );
		assertEquals( 'public', form.fields[4].variable );
		
		assertEquals( DataFormFieldType.text_private, form.fields[5].type );
		assertEquals( 'Password for special access', form.fields[5].label );
		assertEquals( 'password', form.fields[5].variable );
		
		assertEquals( DataFormFieldType.fixed, form.fields[6].type );
		assertEquals( 'Section 2: Features', form.fields[6].values[0] );
		
		assertEquals( DataFormFieldType.list_multi, form.fields[7].type );
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
		
		assertEquals( DataFormFieldType.fixed, form.fields[8].type );
		assertEquals( 'Section 3: Subscriber List', form.fields[8].values[0] );
		
		assertEquals( DataFormFieldType.list_single, form.fields[9].type );
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
		
		assertEquals( DataFormFieldType.fixed, form.fields[10].type );
		assertEquals( 'Section 4: Invitations', form.fields[10].values[0] );
		
		assertEquals( DataFormFieldType.jid_multi, form.fields[11].type );
		assertEquals( 'People to invite', form.fields[11].label );
		assertEquals( 'invitelist', form.fields[11].variable );
		assertEquals( 'Tell all your friends about your new bot!', form.fields[11].desc );
	}
	
	/*
	public function testAuthExt() {
		TODO test with example which include ALL elements!
	}
	*/
	
}

