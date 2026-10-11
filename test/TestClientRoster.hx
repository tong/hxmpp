import utest.Assert.*;
import xmpp.XML;

using xmpp.client.Roster;

class TestClientRoster extends utest.Test {
	function test_subscription() {
		final stream = new xmpp.client.Stream('example.com');
		final sent = new Array<String>();
		stream.output = str -> sent.push(str);
		stream.subscribePresence('romeo@example.net');
		var p = XML.parse(sent[0]).firstElement;
		equals('presence', p.name);
		equals('romeo@example.net', p.get('to'));
		equals('subscribe', p.get('type'));
		stream.unsubscribePresence('romeo@example.net');
		p = XML.parse(sent[1]).firstElement;
		equals('romeo@example.net', p.get('to'));
		equals('unsubscribe', p.get('type'));
	}
}
