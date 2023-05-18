
import utest.Assert.*;
import xmpp.Stanza;
import xmpp.XML;

class TestStanza extends utest.Test {

	function test_error_create() {
		var e = new xmpp.Stanza.Error( cancel, bad_request );
		equals( bad_request, e.condition );
		equals( cancel, e.type );
		isNull( e.by );
		isNull( e.text );
		isNull( e.app );
	}

	function test_error_parse() {
		var e = xmpp.Stanza.Error.fromXML(XML.parse("<error type='cancel'>
          <conflict xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
        </error>").firstElement);
		equals( conflict, e.condition );
		equals( cancel, e.type );
		isNull( e.by );
		isNull( e.text );
		isNull( e.app );
	}

    function test_struct() {
        var e : xmpp.Stanza.Error = { type: cancel, condition:forbidden };
		equals(cancel, e.type);
		equals(forbidden, e.condition);
		isNull(e.by);
		isNull( e.text );
		isNull( e.app );
    }
}
