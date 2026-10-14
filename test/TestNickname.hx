import utest.Assert.*;
import xmpp.Message;
import xmpp.client.Nickname;

using xmpp.client.Nickname;

class TestNickname extends StreamTest {
	function test_nickname() {
		// https://xmpp.org/extensions/xep-0172.html#exchange-subscription
		final p = new xmpp.Presence(null, null, null, subscribe);
		p.to = 'narrator@moby-dick.lit';
		p.nickname('Ishmael').nickname('Ishmael');
		final nicks = p.toXML().elements.filter(e -> e.is(Nickname.XMLNS));
		equals(1, nicks.length);
		equals('nick', nicks[0].name);
		equals('Ishmael', nicks[0].text);
		equals('Ishmael', p.getNickname());
		p.nickname('Starbuck');
		equals('Starbuck', p.getNickname());
		p.nickname(null);
		isNull(p.getNickname());
		equals(0, p.properties.length);

		// https://xmpp.org/extensions/xep-0172.html#exchange-firstmsg
		final m = Message.fromString("<message from='narrator@moby-dick.lit/pda' to='starbuck@moby-dick.lit' type='chat'><body>Call me Ishmael.</body><nick xmlns='http://jabber.org/protocol/nick'>Ishmael</nick></message>");
		equals('Ishmael', m.getNickname());
		isNull(new Message('romeo@example.net', 'hi').getNickname());
		isNull(Message.fromString("<message><nick xmlns='http://jabber.org/protocol/nick'/></message>").getNickname());
		isNull(Message.fromString("<message><nick xmlns='urn:other'>x</nick></message>").getNickname());
	}

	function test_nickname_pep() {
		// https://xmpp.org/extensions/xep-0172.html#pep
		Nickname.publishNickname(stream, 'Ishmael', r -> {});
		final iq = lastSent();
		equals('set', iq.get('type'));
		final publish = iq.firstElement.firstElement;
		equals(xmpp.PubSub.XMLNS, iq.firstElement.get('xmlns'));
		equals('publish', publish.name);
		equals(Nickname.XMLNS, publish.get('node'));
		final nick = publish.firstElement.firstElement;
		equals('nick', nick.name);
		equals(Nickname.XMLNS, nick.get('xmlns'));
		equals('Ishmael', nick.text);
		Nickname.publishNickname(stream, null, r -> {});
		isNull(Nickname.parseNickname(lastSent().firstElement.firstElement.firstElement.firstElement));

		final m = Message.fromString("<message from='narrator@moby-dick.lit' to='starbuck@moby-dick.lit/bridge'><event xmlns='http://jabber.org/protocol/pubsub#event'><items node='http://jabber.org/protocol/nick'><item><nick xmlns='http://jabber.org/protocol/nick'>Ishmael</nick></item></items></event></message>");
		switch xmpp.PubSub.getEvent(m) {
			case Items(node, items, _):
				equals(Nickname.XMLNS, node);
				equals('Ishmael', Nickname.parseNickname(items[0].firstElement));
			case _:
				fail();
		}
	}
}
