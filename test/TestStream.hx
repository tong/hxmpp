
import utest.Assert.*;

class TestStream extends utest.Test {

    function test_client() {
		var stream = new xmpp.client.Stream('example.com');
		equals( 'example.com', stream.domain );
		equals( xmpp.client.Stream.XMLNS, stream.xmlns );
		isNull( stream.lang );
		isNull( stream.id );
		equals( '1.0', stream.version );
		isFalse( stream.ready );
    }

}

