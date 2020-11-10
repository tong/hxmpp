
import utest.Assert.*;
import xmpp.xml.Printer;

class TestPrinter extends utest.Test {

    function test_print() {

        var src = '<node><child ns="my_ns">value</child></node>';

        var str = Printer.print( src, false );
        equals( src, str );

        var str = Printer.print( src, true );
        equals( '<node>
	<child ns="my_ns">
		value
	</child>
</node>', str );

    }
}
