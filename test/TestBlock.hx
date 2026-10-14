import utest.Assert.*;
import xmpp.Message;

class TestBlock extends StreamTest {
	function test_block() {
		xmpp.Block.block(stream, ['romeo@montague.net', 'iago@shakespeare.lit'], r -> {});
		var iq = lastSent();
		equals('set', iq.get('type'));
		isNull(iq.get('to'));
		equals('block', iq.firstElement.name);
		equals('romeo@montague.net,iago@shakespeare.lit', xmpp.Block.getItems(iq.firstElement).join(','));

		xmpp.Block.unblock(stream, ['romeo@montague.net'], r -> {});
		equals('romeo@montague.net', xmpp.Block.getItems(lastSent().firstElement).join(','));
		xmpp.Block.unblock(stream, r -> {});
		equals('unblock', lastSent().firstElement.name);
		equals(0, lastSent().firstElement.elements.length);

		var items:Array<String> = null;
		final iq = xmpp.Block.getBlocklist(stream, r -> items = xmpp.Block.getItems(r.payload));
		stream.recv('<iq type="result" id="${iq.id}"><blocklist xmlns="urn:xmpp:blocking"><item jid="romeo@montague.net"/><item jid="iago@shakespeare.lit"/></blocklist></iq>');
		equals(2, items.length);
	}

	function test_block_pushes() {
		@:privateAccess stream.jid = 'juliet@capulet.com/chamber';
		final pushes = new Array<String>();
		xmpp.Block.handlePushes(stream, (blocked, jids) -> pushes.push('$blocked:${jids.join(",")}'));

		stream.recv('<iq to="juliet@capulet.com/chamber" type="set" id="push1"><block xmlns="urn:xmpp:blocking"><item jid="romeo@montague.net"/></block></iq>');
		equals('true:romeo@montague.net', pushes.join(' '));
		equals('result', lastSent().get('type'));
		equals('push1', lastSent().get('id'));

		stream.recv('<iq from="Juliet@Capulet.com" type="set" id="push2"><unblock xmlns="urn:xmpp:blocking"/></iq>');
		equals('true:romeo@montague.net false:', pushes.join(' '));
		equals('result', lastSent().get('type'));

		// pushes from others are rejected
		stream.recv('<iq from="romeo@montague.net/orchard" type="set" id="push3"><unblock xmlns="urn:xmpp:blocking"><item jid="romeo@montague.net"/></unblock></iq>');
		equals(2, pushes.length);
		equals('error', lastSent().get('type'));
		equals('push3', lastSent().get('id'));
	}

	function test_block_error() {
		final m = Message.fromString('<message type="error" from="romeo@montague.net"><error type="cancel"><not-acceptable xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/><blocked xmlns="urn:xmpp:blocking:errors"/></error></message>');
		isTrue(xmpp.Block.isBlockedError(m.error));
		isFalse(xmpp.Block.isBlockedError(new xmpp.Stanza.Error(cancel, not_acceptable)));
		isFalse(xmpp.Block.isBlockedError(null));
	}
}
