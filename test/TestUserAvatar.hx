import haxe.io.Bytes;
import utest.Assert.*;
import xmpp.Presence;
import xmpp.UserAvatar;
import xmpp.VCardAvatar;
import xmpp.XML;

class TestUserAvatar extends StreamTest {
	function test_publish() {
		final data = Bytes.ofString("not really a png");
		final id = UserAvatar.hash(data);
		equals(haxe.crypto.Sha1.make(data).toHex(), id);
		equals(40, id.length);

		UserAvatar.publishData(stream, data, r -> {});
		final publish = lastSent().firstElement.firstElement;
		equals('publish', publish.name);
		equals(UserAvatar.XMLNS_DATA, publish.get('node'));
		isNull(lastSent().get('to'));
		final item = publish.firstElement;
		equals(id, item.get('id'));
		equals(UserAvatar.XMLNS_DATA, item.firstElement.get('xmlns'));
		equals('not really a png', UserAvatar.parseData(item.firstElement).toString());

		UserAvatar.publishMetadata(stream, [{id: id, bytes: data.length, type: 'image/png', width: 64, height: 32}], r -> {});
		final item = lastSent().firstElement.firstElement.firstElement;
		equals(UserAvatar.XMLNS_METADATA, lastSent().firstElement.firstElement.get('node'));
		equals(id, item.get('id'));
		final infos = UserAvatar.parseMetadata(item.firstElement);
		equals(1, infos.length);
		equals(id, infos[0].id);
		equals(16, infos[0].bytes);
		equals('image/png', infos[0].type);
		equals(64, infos[0].width);
		equals(32, infos[0].height);
		isNull(infos[0].url);

		// no avatar: empty metadata
		UserAvatar.publishMetadata(stream, null, r -> {});
		final metadata = lastSent().firstElement.firstElement.firstElement.firstElement;
		equals('metadata', metadata.name);
		equals(0, metadata.elements.length);
		equals(0, UserAvatar.parseMetadata(metadata).length);
	}

	function test_parse() {
		// https://xmpp.org/extensions/xep-0084.html#example-3 (a notification)
		final items = XML.fromString('<items node="urn:xmpp:avatar:metadata"><item id="111f4b3c50d7b0df729d299bc6f8e9ef9066971f">'
			+ '<metadata xmlns="urn:xmpp:avatar:metadata">'
			+ '<info bytes="12345" height="64" id="111F4B3C50D7B0DF729D299BC6F8E9EF9066971F" type="image/png" width="64"/>'
			+ '<info bytes="78912" id="e8a2b1d6c5f4" type="image/gif" url="http://avatars.example.org/happy.gif"/>'
			+ '<info id="incomplete"/></metadata></item></items>');
		final infos = UserAvatar.parseMetadata(items);
		equals(2, infos.length);
		equals('111f4b3c50d7b0df729d299bc6f8e9ef9066971f', infos[0].id);
		equals(12345, infos[0].bytes);
		equals('http://avatars.example.org/happy.gif', infos[1].url);
		isNull(infos[1].width);
		// a response: <pubsub><items>
		final response = XML.fromString('<pubsub xmlns="http://jabber.org/protocol/pubsub"><items node="urn:xmpp:avatar:data">'
			+ '<item id="x"><data xmlns="urn:xmpp:avatar:data">aGVs\nbG8=</data></item></items></pubsub>');
		equals('hello', UserAvatar.parseData(response).toString());
		isNull(UserAvatar.parseData(XML.fromString('<pubsub xmlns="http://jabber.org/protocol/pubsub"><items node="urn:xmpp:avatar:data"/></pubsub>')));
		isNull(UserAvatar.parseData(null));
		equals(0, UserAvatar.parseMetadata(null).length);

		UserAvatar.loadData(stream, 'juliet@capulet.lit', 'abc', r -> {});
		equals('juliet@capulet.lit', lastSent().get('to'));
		equals('get', lastSent().get('type'));
		final items = lastSent().firstElement.firstElement;
		equals(UserAvatar.XMLNS_DATA, items.get('node'));
		equals('abc', items.firstElement.get('id'));
		UserAvatar.loadMetadata(stream, r -> {});
		isNull(lastSent().get('to'));
		equals('1', lastSent().firstElement.firstElement.get('max_items'));
	}

	function test_vcard_avatar() {
		// https://xmpp.org/extensions/xep-0153.html#example-3
		function presence(x:String):Presence
			return Presence.fromString('<presence from="juliet@capulet.com/balcony">$x</presence>');
		equals('sha1-hash-of-image', VCardAvatar.getPhotoHash(presence('<x xmlns="vcard-temp:x:update"><photo>SHA1-hash-of-image</photo></x>')));
		equals('', VCardAvatar.getPhotoHash(presence('<x xmlns="vcard-temp:x:update"><photo/></x>')));
		isNull(VCardAvatar.getPhotoHash(presence('<x xmlns="vcard-temp:x:update"/>')));
		isNull(VCardAvatar.getPhotoHash(presence('')));

		final p = VCardAvatar.setPhotoHash(new Presence(), 'abc');
		equals('abc', VCardAvatar.getPhotoHash(Presence.fromString(p.toString())));
		VCardAvatar.setPhotoHash(p, '');
		equals('', VCardAvatar.getPhotoHash(Presence.fromString(p.toString())));
		VCardAvatar.setPhotoHash(p);
		isNull(VCardAvatar.getPhotoHash(Presence.fromString(p.toString())));
		equals(1, p.toXML().elements.named('x').length);
	}
}
