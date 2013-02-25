
class TestXMPPPersonalEvent extends TestCase {
	
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
		eq( "Yes", xt.artist );
		eq( 686, xt.length );
		eq( 8, xt.rating );
		eq( "Yessongs", xt.source );
		eq( "Heart of the Sunrise", xt.title );
		eq( "3", xt.track );
		eq( "http://www.yesworld.com/lyrics/Fragile.html#9", xt.uri );
		// test empty
		var empty = xt.empty();
		eq( "tune", empty.nodeName );
		eq( xmpp.pep.UserTune.XMLNS, empty.get( "xmlns" ) );
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
		eq( xmpp.pep.Mood.happy, xt.type );
		eq( "Yay, the mood spec has been approved!", xt.text );
		eq( "ecstatic", xt.extended.mood );
		eq( "http://ik.nu/ralphm", xt.extended.xmlns );
		// test empty
		var empty = xt.empty();
		eq( "mood", empty.nodeName );
		eq( xmpp.pep.UserMood.XMLNS, empty.get( "xmlns" ) );
	}
	
	public function testParseUserActivity() {
		var x = Xml.parse( "
<activity xmlns='http://jabber.org/protocol/activity'>
	<inactive>
		<sleeping>
			<hibernating xmlns='http://www.ursus.info/states'/>
		</sleeping>
	</inactive>
	<text xml:lang='en'>My birthday!</text>
</activity>" ).firstElement();
		var xt = xmpp.pep.UserActivity.parse( x );
		eq( xmpp.pep.Activity.inactive, xt.activity );
		eq( "My birthday!", xt.text );
		eq( "sleeping", xt.extended.activity );
		eq( null, xt.extended.xmlns );
		eq( "hibernating", xt.extended.detail.activity );
		eq( "http://www.ursus.info/states", xt.extended.detail.xmlns );
		// test simple
		x = Xml.parse( "
<activity xmlns='http://jabber.org/protocol/activity'>
	<inactive/>
</activity>" ).firstElement();
		xt = xmpp.pep.UserActivity.parse( x );
		eq( xmpp.pep.Activity.inactive, xt.activity );
		// test empty
		var empty = xt.empty();
		eq( "activity", empty.nodeName );
		eq( xmpp.pep.UserActivity.XMLNS, empty.get( "xmlns" ) );
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
		eq( "Italy", xt.country );
		eq( 45.44, xt.lat );
		eq( "Venice", xt.locality );
		eq( 12.33, xt.lon );
		eq( 20, xt.accuracy );
		// test empty
		var empty = xt.empty();
		eq( "geoloc", empty.nodeName );
		eq( xmpp.pep.UserLocation.XMLNS, empty.get( "xmlns" ) );
	}
	
}
	
	