import utest.Assert.*;
import xmpp.Bookmarks;
import xmpp.Message;
import xmpp.XML;

using StringTools;

class TestBookmarks extends StreamTest {
	function test_set_remove_load() {
		@:privateAccess stream.jid = "juliet@capulet.lit/balcony";
		Bookmarks.set(stream, {jid: "coven@chat.shakespeare.lit", name: "The Coven", autojoin: true, nick: "JC"}, res -> {});
		final pubsub = lastSent().firstElement;
		equals("set", lastSent().get("type"));
		isNull(lastSent().get("to"));
		final publish = pubsub.elements.findElement("publish");
		equals(Bookmarks.XMLNS, publish.get("node"));
		final item = publish.elements.findElement("item");
		equals("coven@chat.shakespeare.lit", item.get("id"));
		final conference = item.elements.findElement("conference");
		equals(Bookmarks.XMLNS, conference.get("xmlns"));
		equals("The Coven", conference.get("name"));
		equals("true", conference.get("autojoin"));
		equals("JC", conference.elements.findElement("nick").text);
		final form = xmpp.DataForm.fromXML(pubsub.elements.findElement("publish-options").elements.findElement("x"));
		equals("http://jabber.org/protocol/pubsub#publish-options", form.getValue("FORM_TYPE"));
		equals("whitelist", form.getValue("pubsub#access_model"));
		equals("max", form.getValue("pubsub#max_items"));

		Bookmarks.remove(stream, "coven@chat.shakespeare.lit", res -> {});
		final retract = lastSent().firstElement.elements.findElement("retract");
		equals(Bookmarks.XMLNS, retract.get("node"));
		equals("true", retract.get("notify"));
		equals("coven@chat.shakespeare.lit", retract.elements.findElement("item").get("id"));

		var loaded:Array<Bookmark> = null;
		Bookmarks.load(stream, res -> loaded = Bookmarks.parseItems(res.payload));
		equals(Bookmarks.XMLNS, lastSent().firstElement.elements.findElement("items").get("node"));
		stream.recv('<iq type="result" id="${lastSent().get("id")}"><pubsub xmlns="http://jabber.org/protocol/pubsub"><items node="urn:xmpp:bookmarks:1">'
			+ '<item id="theplay@conference.shakespeare.lit"><conference xmlns="urn:xmpp:bookmarks:1" name="The Play&apos;s the Thing" autojoin="true"><nick>JC</nick>'
			+ '<extensions><state xmlns="http://myclient.example/bookmark/state" minimized="true"/></extensions></conference></item>'
			+ '<item id="orchard@conference.shakespeare.lit"><conference xmlns="urn:xmpp:bookmarks:1"/></item>'
			+ '<item id="not a jid"><conference xmlns="urn:xmpp:bookmarks:1"/></item>'
			+ '<item id="x@y.z"/>'
			+ '</items></pubsub></iq>');
		equals(2, loaded.length);
		equals("theplay@conference.shakespeare.lit", loaded[0].jid);
		equals("The Play's the Thing", loaded[0].name);
		isTrue(loaded[0].autojoin);
		equals("JC", loaded[0].nick);
		equals(1, loaded[0].extensions.length);
		isFalse(loaded[1].autojoin);
		isNull(loaded[1].name);
		// the extensions are kept
		equals("state", Bookmarks.create(loaded[0]).elements.findElement("extensions").firstElement.name);
		equals(0, Bookmarks.parseItems(null).length);
	}

	function test_changes() {
		@:privateAccess stream.jid = "juliet@capulet.lit/balcony";
		final added = Message.fromString('<message from="juliet@capulet.lit" to="juliet@capulet.lit/balcony"><event xmlns="http://jabber.org/protocol/pubsub#event">'
			+ '<items node="urn:xmpp:bookmarks:1"><item id="theplay@conference.shakespeare.lit"><conference xmlns="urn:xmpp:bookmarks:1" autojoin="1"/></item></items></event></message>');
		final c = Bookmarks.getChanges(stream, added);
		equals(1, c.set.length);
		isTrue(c.set[0].autojoin);
		equals(0, c.removed.length);
		final removed = Message.fromString('<message from="juliet@capulet.lit"><event xmlns="http://jabber.org/protocol/pubsub#event">'
			+ '<items node="urn:xmpp:bookmarks:1"><retract id="theplay@conference.shakespeare.lit"/></items></event></message>');
		equals("theplay@conference.shakespeare.lit", Bookmarks.getChanges(stream, removed).removed[0]);
		// forged, other nodes, no event
		isNull(Bookmarks.getChanges(stream, Message.fromString(added.toString().replace('from="juliet@capulet.lit"', 'from="romeo@montague.lit"'))));
		isNull(Bookmarks.getChanges(stream, Message.fromString('<message from="juliet@capulet.lit"><event xmlns="http://jabber.org/protocol/pubsub#event"><items node="urn:xmpp:avatar:metadata"/></event></message>')));
		isNull(Bookmarks.getChanges(stream, new Message("juliet@capulet.lit", "hi")));
	}
}
