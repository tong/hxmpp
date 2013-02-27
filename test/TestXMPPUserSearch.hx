
class TestXMPPUserSearch extends haxe.unit.TestCase {

	public function testParsing() {
		
		var x = Xml.parse( "<query xmlns='jabber:iq:search'>
	<instructions>Fill in one or more fields to search for any matching Jabber users.</instructions>
	<first/>
    <last/>
    <nick/>
    <email/>
</query>" ).firstElement();
		var s = xmpp.UserSearch.parse( x );
		assertEquals( 'Fill in one or more fields to search for any matching Jabber users.', s.instructions );
		assertEquals( '', s.first );
		assertEquals( '', s.last );
		assertEquals( '', s.nick );
		assertEquals( '', s.email );
		
		x = Xml.parse( "<query xmlns='jabber:iq:search'>
    <last>Capulet</last>
</query>" ).firstElement();
		s = xmpp.UserSearch.parse( x );
		assertEquals( null, s.instructions );
		assertEquals( null, s.first );
		assertEquals( 'Capulet', s.last );
		assertEquals( null, s.nick );
		assertEquals( null, s.email );
		assertEquals( 0, Lambda.count(s.items) );
		assertEquals( null, s.form );
		
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
		assertEquals( null, s.instructions );
		assertEquals( null, s.first );
		assertEquals( null, s.last );
		assertEquals( null, s.nick );
		assertEquals( null, s.email );
		assertEquals( 2, Lambda.count(s.items) );
		assertEquals( null, s.form );
		var i = s.items[0];
		assertEquals( "juliet@capulet.com", i.jid );
		assertEquals( "Juliet", i.first );
		assertEquals( "Capulet", i.last );
		assertEquals( "JuliC", i.nick );
		assertEquals( "juliet@shakespeare.lit", i.email );
		i = s.items[1];
		assertEquals( "tybalt@shakespeare.lit", i.jid );
		assertEquals( "Tybalt", i.first );
		assertEquals( "Capulet", i.last );
		assertEquals( "ty", i.nick );
		assertEquals( "tybalt@shakespeare.lit", i.email );
		
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
		assertEquals( "Use the enclosed form to search", s.instructions );
		assertEquals( null, s.first );
		assertEquals( null, s.last );
		assertEquals( null, s.nick );
		assertEquals( null, s.email );
		assertEquals( 0, Lambda.count(s.items) );
		assertFalse( s.form == null );
	}
	
}
