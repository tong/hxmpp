import utest.Assert.*;
import xmpp.XML;

using xmpp.client.Roster;

class TestClientRoster extends utest.Test {
	function test_subscription() {
		final stream = new xmpp.client.Stream('example.com');
		final sent = new Array<String>();
		stream.output = str -> sent.push(str);
		stream.subscribePresence('romeo@example.net');
		var p = XML.fromString(sent[0]);
		equals('presence', p.name);
		equals('romeo@example.net', p.get('to'));
		equals('subscribe', p.get('type'));
		stream.unsubscribePresence('romeo@example.net');
		p = XML.fromString(sent[1]);
		equals('romeo@example.net', p.get('to'));
		equals('unsubscribe', p.get('type'));
	}
}
