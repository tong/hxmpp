import utest.Assert.*;
import xmpp.Stanza;
import xmpp.XML;

class TestStanza extends utest.Test {
	function test_error_create() {
		var e = new xmpp.Stanza.Error(cancel, bad_request);
		equals(bad_request, e.condition);
		equals(cancel, e.type);
		isNull(e.by);
		isNull(e.text);
		isNull(e.app);
	}

	function test_error_parse() {
		var e = xmpp.Stanza.Error.fromXML(XML.fromString("<error type='cancel'>
          <conflict xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
        </error>"));
		equals(conflict, e.condition);
		equals(cancel, e.type);
		isNull(e.by);
		isNull(e.text);
		isNull(e.app);
	}

	function test_struct() {
		var e:xmpp.Stanza.Error = {type: cancel, condition: forbidden};
		equals(cancel, e.type);
		equals(forbidden, e.condition);
		isNull(e.by);
		isNull(e.text);
		isNull(e.app);
	}

	function test_error_by_and_address() {
		// https://xmpp.org/rfcs/rfc6120.html#stanzas-error-conditions-gone
		final e = xmpp.Stanza.Error.fromXML(XML.fromString('<error by="example.net" type="cancel"><gone xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">xmpp:romeo@afterlife.example.net</gone></error>'));
		equals('example.net', e.by);
		equals(gone, e.condition);
		equals('xmpp:romeo@afterlife.example.net', e.address);
		final xml = e.toXML();
		equals('example.net', xml.get('by'));
		equals('xmpp:romeo@afterlife.example.net', xml.firstElement.text);

		// https://xmpp.org/rfcs/rfc6120.html#stanzas-error-conditions-redirect
		final e = xmpp.Stanza.Error.fromXML(XML.fromString('<error type="modify"><redirect xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">xmpp:characters@conference.example.org</redirect></error>'));
		equals(redirect, e.condition);
		equals('xmpp:characters@conference.example.org', e.address);

		// the address is only kept for gone and redirect
		final e = xmpp.Stanza.Error.fromXML(XML.fromString('<error type="cancel"><conflict xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">x</conflict></error>'));
		isNull(e.address);
	}

	function test_error_missing_values() {
		final e = xmpp.Stanza.Error.fromXML(XML.fromString('<error><text xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">only text</text></error>'));
		equals(undefined_condition, e.condition);
		equals(cancel, e.type);
		equals('only text', e.text);
		final xml = e.toXML();
		equals('undefined-condition', xml.firstElement.name);
		equals('cancel', xml.get('type'));
	}

	function test_error_text_lang() {
		final e = xmpp.Stanza.Error.fromXML(XML.fromString('<error type="modify"><policy-violation xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/><text xmlns="urn:ietf:params:xml:ns:xmpp-stanzas" xml:lang="de">Verboten</text><text xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">Forbidden</text></error>'));
		equals(policy_violation, e.condition);
		equals('Forbidden', e.text);
		isNull(e.lang);

		final e = xmpp.Stanza.Error.fromXML(XML.fromString('<error type="modify"><bad-request xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/><text xmlns="urn:ietf:params:xml:ns:xmpp-stanzas" xml:lang="en">Bad</text></error>'));
		equals('en', e.lang);
		equals('en', e.toXML().elements.named('text')[0].get('xml:lang'));
	}
}
