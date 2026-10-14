import xmpp.XML;

/**
	Test case with a started client stream, recording the sent data.
**/
abstract class StreamTest extends utest.Test {
	var stream:xmpp.client.Stream;
	var sent:Array<String>;

	function setup() {
		sent = [];
		stream = new xmpp.client.Stream('example.com');
		stream.output = str -> sent.push(str);
		stream.start(features -> {});
		stream.recv("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='abc' from='example.com' version='1.0'><stream:features></stream:features>");
	}

	function lastSent():XML
		return XML.fromString(sent[sent.length - 1]);
}
