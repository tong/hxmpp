
import utest.Assert.*;

class TestPrinter extends utest.Test {

    function test_print() {

        var src = '<node><child ns="my_ns">value</child></node>';

        var str = xmpp.extra.Printer.print( src, false );
        equals( src, str );

        var str = xmpp.extra.Printer.print( src, true );
        equals( '<node>
	<child ns="my_ns">
		value
	</child>
</node>', str );

    }
}
