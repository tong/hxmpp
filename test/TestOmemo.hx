import haxe.crypto.Base64;
import haxe.io.Bytes;
import utest.Assert.*;
import xmpp.Message;
import xmpp.Omemo;
import xmpp.PubSub;
import xmpp.XML;

class TestOmemo extends StreamTest {
	// published by python-oldmemo (its etree serialization)
	static final BUNDLE = '<bundle xmlns="eu.siacs.conversations.axolotl"><signedPreKeyPublic signedPreKeyId="1">BQUdCSRanXMd9MvBenpl3mDARKYuWqngpM4qrDn79r1Z</signedPreKeyPublic><signedPreKeySignature>N6LkuNvBxO7gXNSg8vZe2ke0tdhdWtr9t+4mKmkoSbaz3gNPtbMneCCFXN6VM8tOItXSVgGAYJBLBaCu4jUzDQ==</signedPreKeySignature><identityKey>BaaR2bPq7i91LFfbdCol2JRBXfqKqcovmlfisn9NhgZ2</identityKey><prekeys><preKeyPublic preKeyId="6">BSIYqsNMXZYZsrBYlr2+1hDWqLHAKLvj2QjD5hPrXcN8</preKeyPublic><preKeyPublic preKeyId="8">BR+sIs1UrSim7U5V0++nkaaw4VPIUBFPASDmAB4C6WdZ</preKeyPublic></prekeys></bundle>';
	static final ENCRYPTED = '<encrypted xmlns="eu.siacs.conversations.axolotl"><header sid="1"><key rid="2" prekey="true">MwgLEiEF4xD0O9FT1hxJqBEFK97BmOYnZY+wOfTywN7kVA+NrFIaIQUYfpbrx4hS04KnEHZBND/pogScT63oH6is94cLrTrAUiJiMwohBeXV6tRKtKcwP9xoVptLyS1iqMA9Ub7h2NxXm4k0wGMJEAAYACIw+SO4Od4NDqlTltI7YJ2VR6nq+y2VHJtLqslQ1gRSEu0M6xmAXVVuq8JOrxkUcGZ8GMCOqfjfJpwwAQ==</key><iv>8nS+I1S1t2HFGQzQ</iv></header><payload>lpw=</payload></encrypted>';

	function test_deviceList() {
		Omemo.publishDeviceList(stream, [1, 4223], r -> {});
		final publish = lastSent().firstElement.firstElement;
		equals(Omemo.NODE_DEVICELIST, publish.get('node'));
		final item = publish.firstElement;
		equals('current', item.get('id'));
		same([1, 4223], Omemo.parseDeviceList(item));
		// the access model: open
		final form = lastSent().firstElement.elements.named('publish-options')[0].firstElement;
		isTrue(form.toString().indexOf('pubsub#access_model') > 0 && form.toString().indexOf('<value>open</value>') > 0);

		// a notification
		final event = XML.fromString('<message from="juliet@capulet.lit"><event xmlns="http://jabber.org/protocol/pubsub#event">'
			+ '<items node="eu.siacs.conversations.axolotl.devicelist"><item id="current"><list xmlns="eu.siacs.conversations.axolotl">'
			+ '<device id="12345"/><device id="4223"/><device id="x"/><device id="12345"/><device id="99999999999"/></list></item></items></event></message>');
		final e = PubSub.getEvent(Message.fromXML(event));
		switch e {
			case Items(node, items, _):
				equals(Omemo.NODE_DEVICELIST, node);
				same([12345, 4223], Omemo.parseDeviceList(items[0]));
			case _:
				fail('no items');
		}
		// a response, and none
		same([7],
			Omemo.parseDeviceList(XML.fromString('<pubsub xmlns="http://jabber.org/protocol/pubsub"><items node="eu.siacs.conversations.axolotl.devicelist">'
				+ '<item id="current"><list xmlns="eu.siacs.conversations.axolotl"><device id="7"/></list></item></items></pubsub>')));
		same([], Omemo.parseDeviceList(null));
		same([], Omemo.parseDeviceList(XML.fromString('<pubsub xmlns="http://jabber.org/protocol/pubsub"><items node="x"/></pubsub>')));
	}

	function test_bundle() {
		final b = Omemo.parseBundle(XML.fromString(BUNDLE));
		notNull(b);
		equals(33, b.identityKey.length);
		equals(5, b.identityKey.get(0));
		equals(1, b.signedPreKeyId);
		equals(33, b.signedPreKey.length);
		equals(64, b.signedPreKeySignature.length);
		equals(2, b.preKeys.length);
		equals(6, b.preKeys[0].id);
		equals(33, b.preKeys[0].key.length);

		Omemo.publishBundle(stream, 31415, b, r -> {});
		final publish = lastSent().firstElement.firstElement;
		equals(Omemo.NODE_BUNDLES + '31415', publish.get('node'));
		final again = Omemo.parseBundle(publish.firstElement);
		equals(Base64.encode(b.identityKey), Base64.encode(again.identityKey));
		equals(Base64.encode(b.signedPreKeySignature), Base64.encode(again.signedPreKeySignature));
		equals(b.signedPreKeyId, again.signedPreKeyId);
		equals(Base64.encode(b.preKeys[1].key), Base64.encode(again.preKeys[1].key));

		// in a response
		final response = XML.fromString('<pubsub xmlns="http://jabber.org/protocol/pubsub"><items node="eu.siacs.conversations.axolotl.bundles:2">'
			+ '<item id="current">'
			+ BUNDLE
			+ '</item></items></pubsub>');
		equals(2, Omemo.parseBundle(response).preKeys.length);
		// incomplete
		isNull(Omemo.parseBundle(XML.fromString('<bundle xmlns="eu.siacs.conversations.axolotl"><identityKey>BQ==</identityKey></bundle>')));
		isNull(Omemo.parseBundle(null));
	}

	function test_encrypted() {
		final e = Omemo.parseEncrypted(XML.fromString(ENCRYPTED));
		notNull(e);
		equals(1, e.sid);
		equals(1, e.keys.length);
		equals(2, e.keys[0].rid);
		isTrue(e.keys[0].preKey);
		equals(0x33, e.keys[0].data.get(0));
		equals(12, e.iv.length);
		equals(2, e.payload.length);

		final m = new Message('juliet@capulet.lit', null);
		Omemo.addTo(m, {
			sid: 7,
			keys: [
				{rid: 1, data: Bytes.ofString('k1'), preKey: false},
				{rid: 2, data: Bytes.ofString('k2'), preKey: true}
			],
			iv: Bytes.ofString('iv'),
			payload: Bytes.ofString('p')
		});
		equals(Omemo.FALLBACK_BODY, m.body);
		final xml = m.toXML();
		final parsed = Omemo.getEncrypted(Message.fromXML(xml));
		equals(7, parsed.sid);
		equals(2, parsed.keys.length);
		isFalse(parsed.keys[0].preKey);
		isTrue(parsed.keys[1].preKey);
		equals('k2', parsed.keys[1].data.toString());
		equals('p', parsed.payload.toString());
		final eme = xml.elements.named('encryption')[0];
		equals(Omemo.XMLNS, eme.get('namespace'));
		equals(1, xml.elements.named('store').length);

		// empty message (only keys): no payload, no body
		final empty = new Message('juliet@capulet.lit', null);
		Omemo.addTo(empty, {sid: 7, keys: [{rid: 1, data: Bytes.ofString('k'), preKey: false}], iv: Bytes.ofString('iv')});
		isNull(empty.body);
		isNull(Omemo.getEncrypted(Message.fromXML(empty.toXML())).payload);

		isNull(Omemo.getEncrypted(new Message('x@y', 'plain')));
		isNull(Omemo.parseEncrypted(XML.fromString('<encrypted xmlns="eu.siacs.conversations.axolotl"><header/></encrypted>')));
	}
}
