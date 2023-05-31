import utest.Assert.*;
import xmpp.Response;
import xmpp.Stanza;

class TestStream extends utest.Test {

    function test_client_stream() {
		var stream = new xmpp.client.Stream('example.com');
		equals(xmpp.client.Stream.XMLNS, stream.xmlns);
		equals('example.com', stream.domain);
		equals('1.0', stream.version);
		isNull(stream.id);
		isNull(stream.lang);
		isNull(stream.input); 
		isNull(stream.output); 
		isFalse(stream.ready);
	}

    function test_component_stream() {
		var stream = new xmpp.component.Stream("mycomponent", "example.com");
		equals(xmpp.component.Stream.XMLNS, stream.xmlns);
		equals("mycomponent", stream.name);
		equals("example.com", stream.domain);
		equals("1.0", stream.version);
		isNull(stream.id);
        isNull(stream.lang);
		isNull(stream.input); 
		isNull(stream.output); 
		isFalse(stream.ready);
    }
}

