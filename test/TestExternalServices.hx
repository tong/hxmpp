import utest.Assert.*;
import xmpp.ExternalServices;
import xmpp.XML;

class TestExternalServices extends StreamTest {
	function test_request() {
		ExternalServices.request(stream, res -> {});
		equals("get", lastSent().get("type"));
		equals("example.com", lastSent().get("to"));
		equals("services", lastSent().firstElement.name);
		equals(ExternalServices.XMLNS, lastSent().firstElement.get("xmlns"));
		isNull(lastSent().firstElement.get("type"));
		ExternalServices.request(stream, "turn", res -> {});
		equals("turn", lastSent().firstElement.get("type"));
	}

	function test_parse_uri() {
		final services = ExternalServices.parse(XML.fromString('<services xmlns="urn:xmpp:extdisco:2">'
			+ '<service host="stun.shakespeare.lit" port="3478" transport="udp" type="stun"/>'
			+ '<service host="turn.shakespeare.lit" port="3478" transport="udp" type="turn" username="1700000000:juliet" password="a/b+c=" expires="2026-10-15T12:00:00Z" restricted="1"/>'
			+ '<service host="turn.shakespeare.lit" port="5349" transport="tcp" type="turns" username="u" password="p"/>'
			+ '<service host="2001:db8::1" type="stun"/>'
			+ '<service host="ftp.shakespeare.lit" port="20" transport="tcp" type="ftp"/>'
			+ '<service type="stun"/>'
			+ '</services>'));
		equals(5, services.length);
		equals("stun", services[0].type);
		equals(3478, services[0].port);
		equals("udp", services[0].transport);
		equals("1700000000:juliet", services[1].username);
		equals("a/b+c=", services[1].password);
		equals("2026-10-15T12:00:00Z", services[1].expires);
		equals("stun://stun.shakespeare.lit:3478", ExternalServices.uri(services[0]));
		// credentials percent-encoded
		equals("turn://1700000000%3Ajuliet:a%2Fb%2Bc%3D@turn.shakespeare.lit:3478?transport=udp", ExternalServices.uri(services[1]));
		equals("turns://u:p@turn.shakespeare.lit:5349?transport=tcp", ExternalServices.uri(services[2]));
		equals("stun://[2001:db8::1]", ExternalServices.uri(services[3]));
		isNull(ExternalServices.uri(services[4]));
		equals(0, ExternalServices.parse(null).length);
	}
}
