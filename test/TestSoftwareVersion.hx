import utest.Assert.*;
import xmpp.SoftwareVersion;
import xmpp.XML;

class TestSoftwareVersion extends utest.Test {
	function test_parse() {
		final info = SoftwareVersion.parse(XML.fromString('<query xmlns="jabber:iq:version"><name>Exodus</name><version> 0.7.0.4 </version><os>Windows-XP 5.01.2600</os></query>'));
		equals("Exodus", info.name);
		equals("0.7.0.4", info.version);
		equals("Windows-XP 5.01.2600", info.os);
		final info = SoftwareVersion.parse(XML.fromString('<query xmlns="jabber:iq:version"><name>x</name><os/></query>'));
		isNull(info.version);
		isNull(info.os);
		isNull(SoftwareVersion.parse(null).name);
	}

	function test_handle_requests() {
		final sent = new Array<String>();
		final stream = new xmpp.client.Stream("example.com");
		stream.output = str -> sent.push(str);
		stream.start(f -> {});
		stream.recv("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='abc' from='example.com' version='1.0'><stream:features></stream:features>");
		SoftwareVersion.handleRequests(stream, {name: "test", version: "1.0"});
		stream.recv('<iq type="get" id="v1" from="a@example.com/r"><query xmlns="jabber:iq:version"/></iq>');
		final res = XML.fromString(sent[sent.length - 1]);
		equals("result", res.get("type"));
		final info = SoftwareVersion.parse(res.firstElement);
		equals("test", info.name);
		equals("1.0", info.version);
		isNull(info.os);
		stream.recv('<iq type="set" id="v2" from="a@example.com/r"><query xmlns="jabber:iq:version"/></iq>');
		equals("error", XML.fromString(sent[sent.length - 1]).get("type"));
	}
}
