import utest.Assert.*;
import xmpp.Message;
import xmpp.XML;

class TestPep extends StreamTest {
	function test_pep() {
		equals('http://jabber.org/protocol/mood', xmpp.Pep.XMLNS_MOOD);
		equals('http://jabber.org/protocol/tune', xmpp.Pep.XMLNS_TUNE);
		xmpp.Pep.publishActivity(stream, relaxing, r -> {});
		final publish = lastSent().firstElement.firstElement;
		equals('publish', publish.name);
		equals(xmpp.Pep.XMLNS_ACTIVITY, publish.get('node'));
		isNull(publish.get('xmlns'));
	}

	function test_pep_publish() {
		function item():XML
			return lastSent().firstElement.firstElement.firstElement.firstElement;
		function node():String
			return lastSent().firstElement.firstElement.get('node');

		// https://xmpp.org/extensions/xep-0107.html#protocol
		xmpp.Pep.publishMood(stream, happy, 'Yay, the mood spec has been approved!', r -> {});
		equals(xmpp.Pep.XMLNS_MOOD, node());
		equals('happy', item().firstElement.name);
		equals('Yay, the mood spec has been approved!', item().elements.named('text')[0].text);
		xmpp.Pep.publishMood(stream, null, r -> {});
		equals(0, item().elements.length);

		// https://xmpp.org/extensions/xep-0108.html#protocol
		xmpp.Pep.publishActivity(stream, relaxing, 'partying', 'My nurse\'s birthday!', r -> {});
		equals(xmpp.Pep.XMLNS_ACTIVITY, node());
		equals('relaxing', item().firstElement.name);
		equals('partying', item().firstElement.firstElement.name);
		equals("My nurse's birthday!", item().elements.named('text')[0].text);
		xmpp.Pep.publishActivity(stream, null, r -> {});
		equals(0, item().elements.length);

		// https://xmpp.org/extensions/xep-0118.html#protocol
		xmpp.Pep.publishTune(stream, {artist: 'Yes', length: 686, rating: 8, source: 'Yessongs', title: 'Heart of the Sunrise', track: '3'}, r -> {});
		equals(xmpp.Pep.XMLNS_TUNE, node());
		equals('Heart of the Sunrise', item().elements.named('title')[0].text);
		equals('686', item().elements.named('length')[0].text);
		equals(6, item().elements.length);
		xmpp.Pep.publishTune(stream, null, r -> {});
		equals(0, item().elements.length);

		// https://xmpp.org/extensions/xep-0080.html#protocol
		xmpp.Pep.publishLocation(stream, {accuracy: 20, country: 'Italy', lat: 45.44, locality: 'Venice', lon: 12.33}, r -> {});
		equals(xmpp.Pep.XMLNS_GEOLOC, node());
		equals('45.44', item().elements.named('lat')[0].text);
		equals(5, item().elements.length);
	}

	function test_pep_parse() {
		final m = xmpp.Pep.parseMood(XML.fromString('<mood xmlns="http://jabber.org/protocol/mood"><happy/><text>Yay, the mood spec has been approved!</text></mood>'));
		equals(xmpp.Pep.Mood.happy, m.mood);
		equals('Yay, the mood spec has been approved!', m.text);
		isNull(xmpp.Pep.parseMood(XML.fromString('<mood xmlns="http://jabber.org/protocol/mood"/>')).mood);

		final a = xmpp.Pep.parseActivity(XML.fromString('<activity xmlns="http://jabber.org/protocol/activity"><relaxing><partying/></relaxing><text xml:lang="en">My nurse&apos;s birthday!</text></activity>'));
		equals(xmpp.Pep.Activity.relaxing, a.activity);
		equals('partying', a.specific);
		equals("My nurse's birthday!", a.text);

		final t = xmpp.Pep.parseTune(XML.fromString('<tune xmlns="http://jabber.org/protocol/tune"><artist>Yes</artist><length>686</length><rating>8</rating><source>Yessongs</source><title>Heart of the Sunrise</title><track>3</track><uri>http://www.yesworld.com/lyrics/Fragile.html#9</uri></tune>'));
		equals('Yes', t.artist);
		equals(686, t.length);
		equals(8, t.rating);
		equals('Heart of the Sunrise', t.title);
		equals('3', t.track);
		equals('http://www.yesworld.com/lyrics/Fragile.html#9', t.uri);
		isNull(xmpp.Pep.parseTune(XML.fromString('<tune xmlns="http://jabber.org/protocol/tune"/>')).title);

		final l = xmpp.Pep.parseLocation(XML.fromString('<geoloc xmlns="http://jabber.org/protocol/geoloc" xml:lang="en"><accuracy>20</accuracy><country>Italy</country><lat>45.44</lat><locality>Venice</locality><lon>12.33</lon></geoloc>'));
		equals(20.0, l.accuracy);
		equals(45.44, l.lat);
		equals(12.33, l.lon);
		equals('Venice', l.locality);
		isNull(l.street);

		// received as pubsub event
		switch xmpp.PubSub.getEvent(Message.fromString('<message from="romeo@montague.net"><event xmlns="http://jabber.org/protocol/pubsub#event"><items node="http://jabber.org/protocol/tune"><item id="current"><tune xmlns="http://jabber.org/protocol/tune"><title>Heart of the Sunrise</title></tune></item></items></event></message>')) {
			case Items(node, items, _):
				equals(xmpp.Pep.XMLNS_TUNE, node);
				equals('Heart of the Sunrise', xmpp.Pep.parseTune(items[0].firstElement).title);
			case e: fail('unexpected $e');
		}
	}
}
