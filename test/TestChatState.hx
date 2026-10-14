import utest.Assert.*;
import xmpp.ChatState;
import xmpp.Message;
import xmpp.XML;

using xmpp.ChatState;

class TestChatState extends utest.Test {
	function test_chat_state() {
		final m = new Message('romeo@example.net', 'hi');
		m.setChatState(composing);
		m.setChatState(paused);
		m.properties.push(XML.create('other'));
		equals(paused, m.getChatState());
		equals(1, m.toXML().elements.filter(e -> e.is(ChatState.XMLNS)).length);
		m.removeChatState();
		isNull(m.getChatState());
		equals(1, m.properties.length);

		// unknown elements in the namespace are no state
		isNull(Message.fromString('<message><foo xmlns="http://jabber.org/protocol/chatstates"/></message>').getChatState());
		equals(gone, Message.fromString('<message><gone xmlns="http://jabber.org/protocol/chatstates"/></message>').getChatState());

		final n = ChatState.createChatStateMessage('romeo@example.net', composing);
		final xml = n.toXML();
		equals('romeo@example.net', xml.get('to'));
		equals('chat', xml.get('type'));
		equals(1, xml.elements.length);
		equals('composing', xml.firstElement.name);
		equals(ChatState.XMLNS, xml.firstElement.get('xmlns'));
		equals('groupchat', ChatState.createChatStateMessage('room@muc.example.net', active, groupchat).toXML().get('type'));
	}
}
