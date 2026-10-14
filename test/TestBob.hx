import utest.Assert.*;
import xmpp.Message;
import xmpp.Response;
import xmpp.XML;

using xmpp.Oob;

class TestBob extends StreamTest {
	function test_bob() {
		final bytes = haxe.io.Bytes.ofString('hello bob');
		final cid = xmpp.Bob.cid(bytes);
		equals('sha1+${haxe.crypto.Sha1.make(bytes).toHex()}@bob.xmpp.org', cid);

		final xml = xmpp.Bob.create(bytes, 'text/plain', 86400);
		equals(xmpp.Bob.XMLNS, xml.get('xmlns'));
		equals(cid, xml.get('cid'));
		equals('text/plain', xml.get('type'));
		equals('86400', xml.get('max-age'));
		final text:String = xml.text;
		isFalse(text.indexOf('\n') != -1);

		final data = xmpp.Bob.parse(XML.fromString(xml.toString()));
		equals(cid, data.cid);
		equals('text/plain', data.type);
		equals(86400, data.maxAge);
		equals('hello bob', data.bytes.toString());
		isTrue(data.verified);

		// data with line breaks
		final data = xmpp.Bob.parse(XML.fromString('<data xmlns="urn:xmpp:bob" cid="$cid" type="text/plain">aGVsbG8g\n  Ym9i</data>'));
		equals('hello bob', data.bytes.toString());

		// sha-256 cid
		final cid256 = 'sha-256+${haxe.crypto.Sha256.make(bytes).toHex()}@bob.xmpp.org';
		isTrue(xmpp.Bob.parse(XML.fromString('<data xmlns="urn:xmpp:bob" cid="$cid256" type="text/plain">aGVsbG8gYm9i</data>')).verified);

		// unsupported algorithm: not verified, but accepted
		final data = xmpp.Bob.parse(XML.fromString('<data xmlns="urn:xmpp:bob" cid="md5+00ff@bob.xmpp.org" type="text/plain">aGVsbG8gYm9i</data>'));
		isFalse(data.verified);
		equals('hello bob', data.bytes.toString());

		// the example of XEP-0231: the data does not match the hash of the cid
		isNull(xmpp.Bob.parse(XML.fromString('<data xmlns="urn:xmpp:bob" cid="sha1+8f35fef110ffc5df08d579a50083ff9308fb6242@bob.xmpp.org" max-age="86400" type="image/png">iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAABGdBTUEAALGP</data>')));

		// empty data element (no content)
		final data = xmpp.Bob.parse(XML.fromString('<data xmlns="urn:xmpp:bob" cid="$cid"/>'));
		isNull(data.bytes);
		isFalse(data.verified);
	}

	function test_bob_message() {
		final bytes = haxe.io.Bytes.ofString('tiny');
		final m = new Message('romeo@example.net', 'look');
		m.properties.push(xmpp.Bob.create(bytes, 'text/plain', 0));
		m.properties.push(XML.fromString('<data xmlns="urn:xmpp:bob" cid="sha1+0000@bob.xmpp.org" type="text/plain">dGlueQ==</data>'));
		final data = xmpp.Bob.getData(Message.fromString(m.toString()));
		equals(1, data.length);
		equals('tiny', data[0].bytes.toString());
		equals(0, data[0].maxAge);
	}

	function test_bob_request() {
		var response:Response<XML> = null;
		final iq = xmpp.Bob.requestBob(stream, 'ladymacbeth@shakespeare.lit/castle', 'sha1+8f35fef110ffc5df08d579a50083ff9308fb6242@bob.xmpp.org', r -> response = r);
		equals('data', lastSent().firstElement.name);
		equals('get', lastSent().get('type'));
		stream.recv('<iq type="result" id="${iq.id}" from="ladymacbeth@shakespeare.lit/castle"><data xmlns="urn:xmpp:bob" cid="x" type="image/png">AAAA</data></iq>');
		isTrue(response.ok());
		equals('AAAA', response.payload.text);
	}

	function test_bob_handle_requests() {
		final bytes = haxe.io.Bytes.ofString('hello bob');
		final cid = xmpp.Bob.cid(bytes);
		xmpp.Bob.handleRequests(stream, c -> c == cid ? xmpp.Bob.create(bytes, 'text/plain') : null);

		stream.recv('<iq type="get" id="r1" from="romeo@example.net/orchard"><data xmlns="urn:xmpp:bob" cid="$cid"/></iq>');
		var iq = lastSent();
		equals('result', iq.get('type'));
		equals('r1', iq.get('id'));
		equals('hello bob', xmpp.Bob.parse(iq.firstElement).bytes.toString());

		stream.recv('<iq type="get" id="r2" from="romeo@example.net/orchard"><data xmlns="urn:xmpp:bob" cid="sha1+00@bob.xmpp.org"/></iq>');
		iq = lastSent();
		equals('error', iq.get('type'));
		equals('item-not-found', iq.elements.named('error')[0].firstElement.name);
	}
}
