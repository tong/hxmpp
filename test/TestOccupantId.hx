import utest.Assert.*;
import xmpp.Message;
import xmpp.OccupantId;
import xmpp.Presence;

class TestOccupantId extends utest.Test {
	function test_message() {
		// https://xmpp.org/extensions/xep-0421.html#example-3
		final m = Message.fromString('<message from="room@muc.example.com/nick" type="groupchat"><body>Hello</body>'
			+ '<occupant-id xmlns="urn:xmpp:occupant-id:0" id="dd72603deec90a38ba552f7c68cbcc61bca202cd"/></message>');
		equals('dd72603deec90a38ba552f7c68cbcc61bca202cd', OccupantId.get(m.properties));
	}

	function test_presence() {
		final p = Presence.fromString('<presence from="room@muc.example.com/nick"><x xmlns="http://jabber.org/protocol/muc#user"/>'
			+ '<occupant-id xmlns="urn:xmpp:occupant-id:0" id="abc"/></presence>');
		equals('abc', OccupantId.get(p.properties));
	}

	function test_none() {
		isNull(OccupantId.get(Message.fromString('<message><body>hi</body></message>').properties));
		// another namespace, an empty id
		isNull(OccupantId.get(Message.fromString('<message><occupant-id xmlns="urn:other" id="x"/></message>').properties));
		isNull(OccupantId.get(Message.fromString('<message><occupant-id xmlns="urn:xmpp:occupant-id:0" id=""/></message>').properties));
	}
}
