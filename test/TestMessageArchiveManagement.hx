import utest.Assert.*;
import xmpp.MessageArchiveManagement;
import xmpp.Message;
import xmpp.XML;

using StringTools;

class TestMessageArchiveManagement extends StreamTest {
	function result(queryId:String, id:String, from = "juliet@capulet.lit", body = "hi", stamp = "2026-10-15T08:30:00Z"):Message
		return Message.fromString('<message from="$from" to="juliet@capulet.lit/balcony"><result xmlns="urn:xmpp:mam:2" queryid="$queryId" id="$id">'
			+ '<forwarded xmlns="urn:xmpp:forward:0"><delay xmlns="urn:xmpp:delay" stamp="$stamp"/>'
			+ '<message from="romeo@montague.lit/orchard" to="juliet@capulet.lit/balcony" type="chat"><body>$body</body></message>'
			+ '</forwarded></result></message>');

	function test_query() {
		@:privateAccess stream.jid = "juliet@capulet.lit/balcony";
		final mam = new MessageArchiveManagement(stream);
		var page:MamResult = null;
		mam.query({with: "romeo@montague.lit", start: new Date(2026, 9, 1, 0, 0, 0), page: {max: 2, before: ""}}, null, res -> switch res {
			case Page(r): page = r;
			case Failed(e): fail(e.condition);
		});
		final iq = lastSent();
		equals("set", iq.get("type"));
		isNull(iq.get("to"));
		final query = iq.firstElement;
		equals("query", query.name);
		equals(MessageArchiveManagement.XMLNS, query.get("xmlns"));
		final queryId = query.get("queryid");
		notNull(queryId);
		final form = xmpp.DataForm.fromXML(query.elements.findElement("x"));
		equals("submit", form.type);
		equals(MessageArchiveManagement.XMLNS, form.getValue("FORM_TYPE"));
		equals("romeo@montague.lit", form.getValue("with"));
		isTrue(form.getValue("start").startsWith("2026-"));
		final set = query.elements.findElement("set");
		equals("2", set.elements.findElement("max").text);
		notNull(set.elements.findElement("before"));

		// results: consumed, also without from (own archive)
		isTrue(mam.handleMessage(result(queryId, "a1", "juliet@capulet.lit", "first")));
		isTrue(mam.handleMessage(result(queryId, "a2", null, "second")));
		// forged by another entity: consumed but ignored
		isTrue(mam.handleMessage(result(queryId, "a3", "romeo@montague.lit", "forged")));
		// other messages and unknown queries are not consumed
		isFalse(mam.handleMessage(new Message("juliet@capulet.lit", "hello")));
		isFalse(mam.handleMessage(result("other", "a4")));
		isNull(page);

		stream.recv('<iq type="result" id="${iq.get("id")}"><fin xmlns="urn:xmpp:mam:2" complete="true">'
			+ '<set xmlns="http://jabber.org/protocol/rsm"><first index="0">a1</first><last>a2</last><count>2</count></set></fin></iq>');
		notNull(page);
		isTrue(page.complete);
		equals(2, page.items.length);
		equals("a1", page.items[0].id);
		equals("first", page.items[0].message.body);
		equals("romeo@montague.lit/orchard", page.items[0].message.from);
		equals(2026, page.items[0].date.getUTCFullYear());
		equals("second", page.items[1].message.body);
		equals("a1", page.page.first);
		equals("a2", page.page.last);
		equals(2, page.page.count);
		// the query is done: late results are not consumed
		isFalse(mam.handleMessage(result(queryId, "a5")));
	}

	function test_room_and_error() {
		@:privateAccess stream.jid = "juliet@capulet.lit/balcony";
		final mam = new MessageArchiveManagement(stream);
		var error:String = null;
		var page:MamResult = null;
		mam.query({}, "Room@chat.example.org", res -> switch res {
			case Page(r): page = r;
			case Failed(e): error = e.condition;
		});
		final iq = lastSent();
		equals("Room@chat.example.org", iq.get("to"));
		final query = iq.firstElement;
		// no filter, no paging
		equals(0, query.elements.length);
		final queryId = query.get("queryid");
		isTrue(mam.handleMessage(result(queryId, "r1", "room@chat.example.org", "in the room")));
		stream.recv('<iq type="result" id="${iq.get("id")}" from="Room@chat.example.org"><fin xmlns="urn:xmpp:mam:2"/></iq>');
		isFalse(page.complete);
		equals(1, page.items.length);
		isNull(page.page.first);
		isNull(page.page.count);

		mam.query({}, null, res -> switch res {
			case Page(_): fail("no error");
			case Failed(e): error = e.condition;
		});
		stream.recv('<iq type="error" id="${lastSent().get("id")}"><error type="cancel"><feature-not-implemented xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></iq>');
		equals("feature-not-implemented", error);
	}

	function test_parse() {
		isNull(MessageArchiveManagement.parseResult(XML.fromString('<result xmlns="urn:xmpp:mam:2" queryid="q"/>')));
		isNull(MessageArchiveManagement.parseResult(XML.fromString('<result xmlns="urn:xmpp:mam:2" id="x"><forwarded xmlns="urn:xmpp:forward:0"/></result>')));
		final item = MessageArchiveManagement.parseResult(XML.fromString('<result xmlns="urn:xmpp:mam:2" id="x"><forwarded xmlns="urn:xmpp:forward:0"><message><body>b</body></message></forwarded></result>'));
		equals("x", item.id);
		equals("b", item.message.body);
		isNull(item.date);
	}
}
