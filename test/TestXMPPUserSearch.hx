
class TestXMPPUserSearch extends TestCase {

	public function testParsing() {
		
		var x = Xml.parse( "<query xmlns='jabber:iq:search'>
	<instructions>Fill in one or more fields to search for any matching Jabber users.</instructions>
	<first/>
    <last/>
    <nick/>
    <email/>
</query>" ).firstElement();
		var s = xmpp.UserSearch.parse( x );
		eq( 'Fill in one or more fields to search for any matching Jabber users.', s.instructions );
		eq( '', s.first );
		eq( '', s.last );
		eq( '', s.nick );
		eq( '', s.email );
		
		x = Xml.parse( "<query xmlns='jabber:iq:search'>
    <last>Capulet</last>
</query>" ).firstElement();
		s = xmpp.UserSearch.parse( x );
		eq( null, s.instructions );
		eq( null, s.first );
		eq( 'Capulet', s.last );
		eq( null, s.nick );
		eq( null, s.email );
		eq( 0, Lambda.count(s.items) );
		eq( null, s.form );
		
		x = Xml.parse( "<query xmlns='jabber:iq:search'>
    <item jid='juliet@capulet.com'>
      <first>Juliet</first>
      <last>Capulet</last>
      <nick>JuliC</nick>
      <email>juliet@shakespeare.lit</email>
    </item>
    <item jid='tybalt@shakespeare.lit'>
      <first>Tybalt</first>
      <last>Capulet</last>
      <nick>ty</nick>
      <email>tybalt@shakespeare.lit</email>
    </item>
</query>" ).firstElement();
		s = xmpp.UserSearch.parse( x );
		eq( null, s.instructions );
		eq( null, s.first );
		eq( null, s.last );
		eq( null, s.nick );
		eq( null, s.email );
		eq( 2, Lambda.count(s.items) );
		eq( null, s.form );
		var i = s.items[0];
		eq( "juliet@capulet.com", i.jid );
		eq( "Juliet", i.first );
		eq( "Capulet", i.last );
		eq( "JuliC", i.nick );
		eq( "juliet@shakespeare.lit", i.email );
		i = s.items[1];
		eq( "tybalt@shakespeare.lit", i.jid );
		eq( "Tybalt", i.first );
		eq( "Capulet", i.last );
		eq( "ty", i.nick );
		eq( "tybalt@shakespeare.lit", i.email );
		
		x = Xml.parse( "<query xmlns='jabber:iq:search'>
    <instructions>Use the enclosed form to search</instructions>
    <x xmlns='jabber:x:data' type='form'>
      <title>User Directory Search</title>
      <instructions>
        Please provide the following information
        to search for Shakespearean characters.
      </instructions>
      <field type='hidden'
             var='FORM_TYPE'>
        <value>jabber:iq:search</value>
      </field>
      <field type='text-single'
             label='Given Name'
             var='first'/>
      <field type='text-single'
             label='Family Name'
             var='last'/>
      <field type='list-single'
             label='Gender'
             var='x-gender'>
        <option label='Male'><value>male</value></option>
        <option label='Female'><value>female</value></option>
      </field>
    </x>
</query>" ).firstElement();
		s = xmpp.UserSearch.parse( x );
		eq( "Use the enclosed form to search", s.instructions );
		eq( null, s.first );
		eq( null, s.last );
		eq( null, s.nick );
		eq( null, s.email );
		eq( 0, Lambda.count(s.items) );
		af( s.form == null );
	}
	
}
