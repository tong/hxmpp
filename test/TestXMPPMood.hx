
/**
	Testunit for xmpp.Mood
*/
class TestXMPPMood extends haxe.unit.TestCase {
	
	public function testParsing() {
		var q = Xml.parse( "
<mood xmlns='http://jabber.org/protocol/mood'>
  <happy/>
  <text>Yay, the mood spec has been approved!</text>
</mood>
" ).firstElement();
		var m = xmpp.UserMood.parse( q );
		assertEquals( xmpp.Mood.happy, m.mood );
		assertEquals( 'Yay, the mood spec has been approved!', m.text );
	}
	
	public function testCreation() {
		var m = new xmpp.UserMood( xmpp.Mood.happy, "Yay, the mood spec has been approved!" );
		assertEquals( xmpp.Mood.happy, m.mood );
		assertEquals( 'Yay, the mood spec has been approved!', m.text );
	}
	
}
