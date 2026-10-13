import utest.Assert.*;
import xmpp.EntityCapabilities;
import xmpp.Response;
import xmpp.ServiceDiscovery;
import xmpp.XML;

class TestEntityCapabilities extends utest.Test {
	function test_verification_string_simple() {
		// https://xmpp.org/extensions/xep-0115.html#ver-gen-simple
		final info:DiscoInfo = {
			identities: [{category: "client", type: "pc", name: "Exodus 0.9.1"}],
			features: [
				"http://jabber.org/protocol/disco#info",
				"http://jabber.org/protocol/disco#items",
				"http://jabber.org/protocol/muc",
				"http://jabber.org/protocol/caps"
			],
			forms: []
		};
		equals("QgayPKawpkPSDYmwT/WM94uAlu0=", EntityCapabilities.verificationString(info));
		isTrue(EntityCapabilities.verify(info, "QgayPKawpkPSDYmwT/WM94uAlu0="));
		isFalse(EntityCapabilities.verify(info, "QgayPKawpkPSDYmwT/WM94uAlu0=", "sha-256"));
	}

	function test_verification_string_complex() {
		// https://xmpp.org/extensions/xep-0115.html#ver-gen-complex
		final info = ServiceDiscovery.parseInfo(XML.fromString('<query xmlns="http://jabber.org/protocol/disco#info">
			<identity xml:lang="en" category="client" name="Psi 0.11" type="pc"/>
			<identity xml:lang="el" category="client" name="Ψ 0.11" type="pc"/>
			<feature var="http://jabber.org/protocol/caps"/>
			<feature var="http://jabber.org/protocol/disco#info"/>
			<feature var="http://jabber.org/protocol/disco#items"/>
			<feature var="http://jabber.org/protocol/muc"/>
			<x xmlns="jabber:x:data" type="result">
				<field var="FORM_TYPE" type="hidden"><value>urn:xmpp:dataforms:softwareinfo</value></field>
				<field var="ip_version"><value>ipv4</value><value>ipv6</value></field>
				<field var="os"><value>Mac</value></field>
				<field var="os_version"><value>10.5.1</value></field>
				<field var="software"><value>Psi</value></field>
				<field var="software_version"><value>0.11</value></field>
			</x>
		</query>'));
		equals("q07IKJEyjvHSyhy//CH0CxmKi8w=", EntityCapabilities.verificationString(info));
	}

	function test_element() {
		final c = EntityCapabilities.createElement("https://example.com/client", "abc=");
		equals("c", c.name);
		isTrue(c.is(EntityCapabilities.XMLNS));
		equals("sha-1", c.get("hash"));
		equals("https://example.com/client", c.get("node"));
		equals("abc=", c.get("ver"));

		final presence = new xmpp.Presence();
		isNull(EntityCapabilities.parse(presence));
		presence.properties.push(c);
		final caps = EntityCapabilities.parse(xmpp.Presence.fromString(presence.toString()));
		equals("https://example.com/client", caps.node);
		equals("abc=", caps.ver);
		equals("sha-1", caps.hash);
	}

	function test_handle_requests() {
		final sent = new Array<String>();
		final stream = new xmpp.client.Stream("example.com");
		stream.output = str -> sent.push(str);
		stream.start(f -> {});
		stream.recv("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='abc' from='example.com' version='1.0'><stream:features></stream:features>");
		xmpp.Ping.handleRequests(stream);
		final node = "https://example.com/client";
		final caps = EntityCapabilities.handleRequests(stream, {category: "client", type: "console", name: "test"}, node, ["urn:example"]);
		final ver = caps().get("ver");

		function request(?node:String):XML {
			final q = (node != null) ? ' node="$node"' : '';
			stream.recv('<iq type="get" id="q" from="a@example.com/r"><query xmlns="http://jabber.org/protocol/disco#info"$q/></iq>');
			return XML.fromString(sent[sent.length - 1]);
		}

		// the advertised verification string matches the disco#info result
		final res = request('$node#$ver');
		equals("result", res.get("type"));
		equals('$node#$ver', res.firstElement.get("node"));
		final info = ServiceDiscovery.parseInfo(res.firstElement);
		isTrue(info.features.contains("urn:example"));
		isTrue(info.features.contains("urn:xmpp:ping"));
		isTrue(EntityCapabilities.verify(info, ver));

		// requests without node are answered too
		equals("result", request().get("type"));

		// other nodes are unknown
		equals("error", request('$node#other').get("type"));
	}
}
