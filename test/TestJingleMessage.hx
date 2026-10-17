import utest.Assert.*;
import xmpp.JingleMessage;
import xmpp.Message;

class TestJingleMessage extends utest.Test {
	function test_propose() {
		final m = JingleMessage.create("juliet@capulet.example", propose, "a73sjjvkla37jfea", {media: ["audio", "video"]});
		equals(chat, m.type);
		final xml = m.toXML();
		final e = xml.elements.named("propose")[0];
		equals(JingleMessage.XMLNS, e.get("xmlns"));
		equals("a73sjjvkla37jfea", e.get("id"));
		equals(2, e.elements.named("description").length);
		equals(xmpp.JingleRtp.XMLNS, e.elements.named("description")[0].get("xmlns"));
		equals(1, xml.elements.named("store").length);
		final info = JingleMessage.parse(Message.fromString(xml.toString()));
		equals(propose, info.action);
		equals("a73sjjvkla37jfea", info.id);
		same(["audio", "video"], info.media);
		isNull(info.reason);
		isFalse(info.tieBreak);
	}

	function test_reason() {
		final m = JingleMessage.create("juliet@capulet.example", retract, "id1", {reason: {condition: cancel}});
		final info = JingleMessage.parse(Message.fromString(m.toXML().toString()));
		equals(retract, info.action);
		equals("cancel", (info.reason.condition : String));
		same([], info.media);
		// a rejection of another client (example of the XEP)
		final rejected = JingleMessage.parse(Message.fromString('<message from="juliet@capulet.example/phone" to="romeo@montague.example/orchard" type="chat"><reject xmlns="urn:xmpp:jingle-message:0" id="id2"><reason xmlns="urn:xmpp:jingle:1"><busy/><text>in a meeting</text></reason><tie-break/></reject><store xmlns="urn:xmpp:hints"/></message>'));
		equals(reject, rejected.action);
		equals("busy", (rejected.reason.condition : String));
		equals("in a meeting", rejected.reason.text);
		isTrue(rejected.tieBreak);
		final finished = JingleMessage.parse(Message.fromString('<message type="chat"><finish xmlns="urn:xmpp:jingle-message:0" id="old"><reason xmlns="urn:xmpp:jingle:1"><expired/></reason><migrated to="new"/></finish></message>'));
		equals(finish, finished.action);
		equals("new", finished.migrated);
	}

	function test_other() {
		isNull(JingleMessage.parse(new Message("juliet@capulet.example", "hi")));
		// without id, other namespace, unknown action
		isNull(JingleMessage.parse(Message.fromString('<message><propose xmlns="urn:xmpp:jingle-message:0"/></message>')));
		isNull(JingleMessage.parse(Message.fromString('<message><propose xmlns="urn:example" id="x"/></message>')));
		isNull(JingleMessage.parse(Message.fromString('<message><hold xmlns="urn:xmpp:jingle-message:0" id="x"/></message>')));
		// the legacy accept
		equals(accept, JingleMessage.parse(Message.fromString('<message><accept xmlns="urn:xmpp:jingle-message:0" id="x"/></message>')).action);
	}
}
