import utest.Assert.*;
import xmpp.Fallback;
import xmpp.Message;
import xmpp.MessageModeration;
import xmpp.MessageRetraction;

using xmpp.MessageRetraction;

class TestMessageRetraction extends StreamTest {
	function test_retract() {
		final m = new Message('lord@capulet.example').retract('origin-id-1');
		final xml = m.toXML();
		final retract = xml.elements.named('retract')[0];
		equals(MessageRetraction.XMLNS, retract.get('xmlns'));
		equals('origin-id-1', retract.get('id'));
		equals(MessageRetraction.FALLBACK, m.body);
		isTrue(Fallback.has(m, MessageRetraction.XMLNS));
		equals('', Fallback.strip(m, MessageRetraction.XMLNS));
		equals(1, xml.elements.named('store').length);
		notNull(m.id);

		final r = (m.toString() : Message).getRetraction();
		equals('origin-id-1', r.id);
		isFalse(r.moderated);
		isNull(r.moderatedBy);
		isNull(new Message('lord@capulet.example', 'hi').getRetraction());

		// again: one retract element, own fallback text
		m.retract('other', 'deleted');
		equals(1, m.toXML().elements.named('retract').length);
		equals(1, m.toXML().elements.named('fallback').length);
		equals('other', m.getRetraction().id);
		equals('deleted', m.body);
	}

	function test_parse() {
		// https://xmpp.org/extensions/xep-0424.html#example-1
		final m = Message.fromString('<message type="chat" to="lord@capulet.example" id="retract-message-1">'
			+ '<retract id="origin-id-1" xmlns="urn:xmpp:message-retract:1"/>'
			+ '<fallback xmlns="urn:xmpp:fallback:0" for="urn:xmpp:message-retract:1"/>'
			+ '<body>/me retracted a previous message, but it\'s unsupported by your client.</body>'
			+ '<store xmlns="urn:xmpp:hints"/></message>');
		equals('origin-id-1', m.getRetraction().id);
		isNull(Message.fromString('<message><retract xmlns="urn:xmpp:message-retract:1"/></message>').getRetraction());
		// an older version
		isNull(Message.fromString('<message><retract id="x" xmlns="urn:xmpp:message-retract:0"/></message>').getRetraction());
	}

	function test_moderated() {
		// https://xmpp.org/extensions/xep-0425.html#example-3
		final m = Message.fromString('<message type="groupchat" from="room@muc.example" id="retraction-id-1">'
			+ '<retract id="stanza-id-1" xmlns="urn:xmpp:message-retract:1">'
			+ '<moderated by="room@muc.example/macbeth" xmlns="urn:xmpp:message-moderate:1">'
			+ '<occupant-id xmlns="urn:xmpp:occupant-id:0" id="dd72603deec90a38ba552f7c68cbcc61bca202cd"/></moderated>'
			+ '<reason>This message contains inappropriate content for this forum</reason></retract></message>');
		final r = m.getRetraction();
		equals('stanza-id-1', r.id);
		isTrue(r.moderated);
		equals('room@muc.example/macbeth', r.moderatedBy);
		equals('This message contains inappropriate content for this forum', r.reason);
	}

	function test_moderate() {
		// https://xmpp.org/extensions/xep-0425.html#example-1
		var result:Null<Bool> = null;
		final iq = MessageModeration.moderate(stream, 'room@muc.example', 'stanza-id-1', 'inappropriate', r -> result = r.error == null);
		final xml = lastSent();
		equals('set', xml.get('type'));
		equals('room@muc.example', xml.get('to'));
		final moderate = xml.firstElement;
		equals('moderate', moderate.name);
		equals(MessageModeration.XMLNS, moderate.get('xmlns'));
		equals('stanza-id-1', moderate.get('id'));
		equals(MessageRetraction.XMLNS, moderate.elements.named('retract')[0].get('xmlns'));
		equals('inappropriate', moderate.elements.named('reason')[0].text);
		stream.recv('<iq type="result" id="${iq.id}" from="room@muc.example"/>');
		isTrue(result);
		MessageModeration.moderate(stream, 'room@muc.example', 'x', r -> {});
		equals(0, lastSent().firstElement.elements.named('reason').length);
	}
}
