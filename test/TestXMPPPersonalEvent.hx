
/**
	Testunit for xmpp.pep classes.
*/
class TestXMPPPersonalEvent extends haxe.unit.TestCase {
	
	public function testUserTune() {
		var x = Xml.parse( "
<tune xmlns='http://jabber.org/protocol/tune'>
	<artist>Yes</artist>
	<length>686</length>
	<rating>8</rating>
	<source>Yessongs</source>
	<title>Heart of the Sunrise</title>
	<track>3</track>
	<uri>http://www.yesworld.com/lyrics/Fragile.html#9</uri>
</tune>" ).firstElement();
		var xt = xmpp.pep.UserTune.parse( x );
		assertEquals( "Yes", xt.artist );
		assertEquals( 686, xt.length );
		assertEquals( 8, xt.rating );
		assertEquals( "Yessongs", xt.source );
		assertEquals( "Heart of the Sunrise", xt.title );
		assertEquals( "3", xt.track );
		assertEquals( "http://www.yesworld.com/lyrics/Fragile.html#9", xt.uri );
		// test empty
		var empty = xt.empty();
		assertEquals( "tune", empty.nodeName );
		assertEquals( xmpp.pep.UserTune.XMLNS, empty.get( "xmlns" ) );
	}
	
	public function testUserMood() {
		var x = Xml.parse( "
<mood xmlns='http://jabber.org/protocol/mood'>
	<happy>
    	<ecstatic xmlns='http://ik.nu/ralphm'/>
	</happy>
	<text>Yay, the mood spec has been approved!</text>
</mood>" ).firstElement();
		var xt = xmpp.pep.UserMood.parse( x );
		assertEquals( xmpp.pep.Mood.happy, xt.type );
		assertEquals( "Yay, the mood spec has been approved!", xt.text );
		assertEquals( "ecstatic", xt.extended.mood );
		assertEquals( "http://ik.nu/ralphm", xt.extended.xmlns );
		// test empty
		var empty = xt.empty();
		assertEquals( "mood", empty.nodeName );
		assertEquals( xmpp.pep.UserMood.XMLNS, empty.get( "xmlns" ) );
	}
	
	public function testParseUserActivity() {
		var x = Xml.parse( "
<activity xmlns='http://jabber.org/protocol/activity'>
	<inactive>
		<sleeping>
			<hibernating xmlns='http://www.ursus.info/states'/>
		</sleeping>
	</inactive>
	<text xml:lang='en'>My nurse&apos;s birthday!</text>
</activity>" ).firstElement();
		var xt = xmpp.pep.UserActivity.parse( x );
		assertEquals( xmpp.pep.Activity.inactive, xt.activity );
		assertEquals( "My nurse&apos;s birthday!", xt.text );
		assertEquals( "sleeping", xt.extended.activity );
		assertEquals( null, xt.extended.xmlns );
		assertEquals( "hibernating", xt.extended.detail.activity );
		assertEquals( "http://www.ursus.info/states", xt.extended.detail.xmlns );
		// test simple
		x = Xml.parse( "
<activity xmlns='http://jabber.org/protocol/activity'>
	<inactive/>
</activity>" ).firstElement();
		xt = xmpp.pep.UserActivity.parse( x );
		assertEquals( xmpp.pep.Activity.inactive, xt.activity );
		// test empty
		var empty = xt.empty();
		assertEquals( "activity", empty.nodeName );
		assertEquals( xmpp.pep.UserActivity.XMLNS, empty.get( "xmlns" ) );
	}
	
	public function testUserGeolocation() {
		var x = Xml.parse( "
<geoloc xmlns='http://jabber.org/protocol/geoloc' xml:lang='en'>
	<country>Italy</country>
	<lat>45.44</lat>
	<locality>Venice</locality>
	<lon>12.33</lon>
	<accuracy>20</accuracy>
</geoloc>" ).firstElement();
		var xt = xmpp.pep.UserLocation.parse( x );
		assertEquals( "Italy", xt.country );
		assertEquals( 45.44, xt.lat );
		assertEquals( "Venice", xt.locality );
		assertEquals( 12.33, xt.lon );
		assertEquals( 20, xt.accuracy );
		// test empty
		var empty = xt.empty();
		assertEquals( "geoloc", empty.nodeName );
		assertEquals( xmpp.pep.UserLocation.XMLNS, empty.get( "xmlns" ) );
	}
	
}
	
	