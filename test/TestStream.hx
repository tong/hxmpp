
import utest.Assert.*;

class TestStream extends utest.Test {

    function test_client_stream() {

		var stream = new xmpp.client.Stream('example.com');
		equals( xmpp.client.Stream.XMLNS, stream.xmlns );
		equals( 'example.com', stream.domain );
		equals( '1.0', stream.version );
		isNull( stream.id );
		isNull( stream.lang );
		isNull( stream.input ); 
		isNull( stream.output ); 

		isFalse( stream.ready );
	}
	
	/* function test_get() {
		var stream = new xmpp.client.Stream('example.com');
		stream.get( 'abc', r -> {});
	} */

}

