import utest.Assert.*;
import xmpp.LastMessageCorrection;
import xmpp.Message;

using xmpp.LastMessageCorrection;

class TestLastMessageCorrection extends utest.Test {
	function test_last_message_correction() {
		final m = new Message('romeo@example.net', 'fixed').correct('msg42');
		final replace = m.toXML().elements.named('replace')[0];
		equals(LastMessageCorrection.XMLNS, replace.get('xmlns'));
		equals('msg42', replace.get('id'));
		notNull(m.id);
		notEquals('msg42', m.id);

		final m:Message = m.toString();
		equals('msg42', m.correction());
		isNull(new Message('romeo@example.net', 'hi').correction());

		// correcting again replaces the mark, the own id is kept
		final c = new Message('romeo@example.net', 'fixed');
		c.id = 'own';
		c.correct('a').correct('b');
		equals(1, c.toXML().elements.named('replace').length);
		equals('b', c.correction());
		equals('own', c.id);
		isNull(new Message('romeo@example.net', 'x').correct(null).correction());
	}

	function test_last_message_correction_valid() {
		// https://xmpp.org/extensions/xep-0308.html#business
		final original = Message.fromString('<message from="romeo@montague.net/orchard" type="chat" id="bad1"><body>airlock</body></message>');
		function correction(from:String, id = 'bad1', type = 'chat'):Message
			return Message.fromString('<message from="$from" type="$type" id="good1"><body>window</body><replace id="$id" xmlns="urn:xmpp:message-correct:0"/></message>');
		isTrue(LastMessageCorrection.isValidCorrection(original, correction('romeo@montague.net/orchard')));
		// other resource of the same user, case-insensitive
		isTrue(LastMessageCorrection.isValidCorrection(original, correction('Romeo@Montague.net/garden')));
		isFalse(LastMessageCorrection.isValidCorrection(original, correction('tybalt@capulet.net/street')));
		isFalse(LastMessageCorrection.isValidCorrection(original, correction('romeo@montague.net/orchard', 'other')));
		isFalse(LastMessageCorrection.isValidCorrection(original, new Message('romeo@example.net', 'hi')));

		// groupchat: the full jid (nick) must match
		final original = Message.fromString('<message from="room@muc.example.net/romeo" type="groupchat" id="bad1"><body>airlock</body></message>');
		isTrue(LastMessageCorrection.isValidCorrection(original, correction('room@muc.example.net/romeo', 'bad1', 'groupchat')));
		isFalse(LastMessageCorrection.isValidCorrection(original, correction('room@muc.example.net/tybalt', 'bad1', 'groupchat')));
	}
}
