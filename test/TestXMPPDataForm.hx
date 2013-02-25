
class TestXMPPDataForm extends TestCase {
	
	public function testParse() {
		// example src from http://xmpp.org/extensions/xep-0004.html
		// TODO test with example which include ALL elements!
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

		eq( 'Bot Configuration', form.title );
		eq( 'Fill out this form to configure your new bot!', form.instructions );
		eq( xmpp.dataform.FieldType.hidden, form.fields[0].type );
		eq( 'FORM_TYPE', form.fields[0].variable );
		eq( 'jabber:bot', form.fields[0].values[0] );
		
		eq( xmpp.dataform.FieldType.fixed, form.fields[1].type );
		eq( 'Section 1: Bot Info', form.fields[1].values[0] );
		
		eq( xmpp.dataform.FieldType.text_single, form.fields[2].type );
		eq( 'botname', form.fields[2].variable );
		eq( 'The name of your bot', form.fields[2].label );
		
		eq( xmpp.dataform.FieldType.text_multi, form.fields[3].type );
		eq( 'Helpful description of your bot', form.fields[3].label );
		eq( 'description', form.fields[3].variable );
		
//TODO !!!! (throws error on java target)
//eq( xmpp.dataform.FieldType.boolean, form.fields[4].type );
		eq( 'Public bot?', form.fields[4].label );
		eq( 'public', form.fields[4].variable );
		
		eq( xmpp.dataform.FieldType.text_private, form.fields[5].type );
		eq( 'Password for special access', form.fields[5].label );
		eq( 'password', form.fields[5].variable );
		
		eq( xmpp.dataform.FieldType.fixed, form.fields[6].type );
		eq( 'Section 2: Features', form.fields[6].values[0] );
		
		eq( xmpp.dataform.FieldType.list_multi, form.fields[7].type );
		eq( 'What features will the bot support?', form.fields[7].label );
		eq( 'features', form.fields[7].variable );
		eq( 'Contests', form.fields[7].options[0].label );
		eq( 'contests', form.fields[7].options[0].value );
		eq( 'News', form.fields[7].options[1].label );
		eq( 'news', form.fields[7].options[1].value );
		eq( 'Polls', form.fields[7].options[2].label );
		eq( 'polls', form.fields[7].options[2].value );
		eq( 'Reminders', form.fields[7].options[3].label );
		eq( 'reminders', form.fields[7].options[3].value );
		eq( 'Search', form.fields[7].options[4].label );
		eq( 'search', form.fields[7].options[4].value );
		eq( 'news', form.fields[7].values[0] );
		eq( 'search', form.fields[7].values[1] );
		
		eq( xmpp.dataform.FieldType.fixed, form.fields[8].type );
		eq( 'Section 3: Subscriber List', form.fields[8].values[0] );
		
		eq( xmpp.dataform.FieldType.list_single, form.fields[9].type );
		eq( 'Maximum number of subscribers', form.fields[9].label );
		eq( 'maxsubs', form.fields[9].variable );
		eq( '20', form.fields[9].values[0] );
		eq( '10', form.fields[9].options[0].label );
		eq( '10', form.fields[9].options[0].value );
		eq( '20', form.fields[9].options[1].label );
		eq( '20', form.fields[9].options[1].value );
		eq( '30', form.fields[9].options[2].label );
		eq( '30', form.fields[9].options[2].value );
		eq( '50', form.fields[9].options[3].label );
		eq( '50', form.fields[9].options[3].value );
		eq( '100', form.fields[9].options[4].label );
		eq( '100', form.fields[9].options[4].value );
		eq( 'None', form.fields[9].options[5].label );
		eq( 'none', form.fields[9].options[5].value );
		
		eq( xmpp.dataform.FieldType.fixed, form.fields[10].type );
		eq( 'Section 4: Invitations', form.fields[10].values[0] );
		
		eq( xmpp.dataform.FieldType.jid_multi, form.fields[11].type );
		eq( 'People to invite', form.fields[11].label );
		eq( 'invitelist', form.fields[11].variable );
		eq( 'Tell all your friends about your new bot!', form.fields[11].desc );
	}
	
	/*
	public function testBuild() {
		//TODO
	}
	*/
	
}
