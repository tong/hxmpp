
import xmpp.EventLog;

class TestXMPPEventLog extends haxe.unit.TestCase {
	
	public function test() {

		var x = Xml.parse( "
<log xmlns='urn:xmpp:eventlog' timestamp='2013-11-10T15:52:23Z'>
	<message>Something happened.</message>
</log>" ).firstElement();

		var e = EventLog.parse( x );

		assertEquals( '2013-11-10T15:52:23Z', e.timestamp );
		assertEquals( 'Something happened.', e.messages[0] );
		assertEquals( 1, e.messages.length );
		assertEquals( 0, e.tags.length );

		x = Xml.parse( "
<log xmlns='urn:xmpp:eventlog' timestamp='2013-11-10T16:07:01Z' type='informational' level='minor'>
	<message>Current resources.</message>
	<tag name='RAM' value='1655709892' type='xs:long'/>
	<tag name='CPU' value='75.45' type='xs:double'/>
	<tag name='HardDrive' value='163208757248' type='xs:long'/>
</log>" ).firstElement();

		e = EventLog.parse( x );

		assertEquals( 'Current resources.', e.messages[0] );
		
		assertEquals( 'RAM', e.tags[0].name );
		assertEquals( '1655709892', e.tags[0].value );
		assertEquals( 'xs:long', e.tags[0].type );
		
		assertEquals( 'CPU', e.tags[1].name );
		assertEquals( '75.45', e.tags[1].value );
		assertEquals( 'xs:double', e.tags[1].type );

		assertEquals( 'HardDrive', e.tags[2].name );
		assertEquals( '163208757248', e.tags[2].value );
		assertEquals( 'xs:long', e.tags[2].type );
	}

}
