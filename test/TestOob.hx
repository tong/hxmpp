import utest.Assert.*;
import xmpp.Message;

using xmpp.Oob;

class TestOob extends StreamTest {
	function test_oob() {
		equals('jabber:iq:oob', xmpp.Oob.XMLNS);
		equals('jabber:x:oob', xmpp.Oob.XMLNS_X);

		// https://xmpp.org/extensions/xep-0066.html#x-oob
		final m = new Message('romeo@example.net').setOob('https://example.com/a.jpg', 'A picture');
		final x = m.toXML().elements.named('x')[0];
		equals('https://example.com/a.jpg', x.elements.named('url')[0].text);
		equals('A picture', x.elements.named('desc')[0].text);
		equals(0, x.elements.named('description').length);
		final data = Message.fromString(m.toString()).getOob();
		equals('https://example.com/a.jpg', data.url);
		equals('A picture', data.desc);

		final p = xmpp.Presence.fromString('<presence><x xmlns="jabber:x:oob"><url>http://www.jabber.org/images/psa-license.jpg</url></x></presence>');
		final data = p.getOob();
		equals('http://www.jabber.org/images/psa-license.jpg', data.url);
		isNull(data.desc);

		isNull(new Message('romeo@example.net', 'hi').getOob());
		isNull(Message.fromString('<message><other xmlns="jabber:x:oob"><url>x</url></other></message>').getOob());
	}

	function test_oob_request() {
		// https://xmpp.org/extensions/xep-0066.html#iq-oob
		xmpp.Oob.oob(stream, 'MaineBoy@jabber.org/home', 'http://www.jabber.org/images/psa-license.jpg', 'A license to Jabber!', r -> {});
		final iq = lastSent();
		equals('set', iq.get('type'));
		equals('MaineBoy@jabber.org/home', iq.get('to'));
		equals('http://www.jabber.org/images/psa-license.jpg', iq.firstElement.elements.named('url')[0].text);
		equals('A license to Jabber!', iq.firstElement.elements.named('desc')[0].text);
	}

	function test_oob_handle_requests() {
		final requests = new Array<{url:String, desc:Null<String>, respond:xmpp.Oob.OobResult->Void}>();
		xmpp.Oob.handleRequests(stream, (url, desc, from, respond) -> requests.push({url: url, desc: desc, respond: respond}));
		function request(id:String)
			stream.recv('<iq type="set" id="$id" from="stpeter@jabber.org/work"><query xmlns="jabber:iq:oob"><url>http://www.jabber.org/images/psa-license.jpg</url><desc>A license to Jabber!</desc></query></iq>');

		final count = sent.length;
		request('o1');
		equals(1, requests.length);
		equals('A license to Jabber!', requests[0].desc);
		// no response before the file was retrieved
		equals(count, sent.length);
		requests[0].respond(Fetched);
		equals('result', lastSent().get('type'));
		equals('o1', lastSent().get('id'));

		request('o2');
		requests[1].respond(Failed);
		equals('error', lastSent().get('type'));
		equals('item-not-found', lastSent().elements.named('error')[0].firstElement.name);

		request('o3');
		requests[2].respond(Rejected);
		equals('not-acceptable', lastSent().elements.named('error')[0].firstElement.name);

		stream.recv('<iq type="set" id="o4" from="stpeter@jabber.org/work"><query xmlns="jabber:iq:oob"/></iq>');
		equals('bad-request', lastSent().elements.named('error')[0].firstElement.name);
	}
}
