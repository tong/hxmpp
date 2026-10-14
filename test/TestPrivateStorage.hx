import utest.Assert.*;
import xmpp.Response;
import xmpp.XML;

class TestPrivateStorage extends StreamTest {
	function test_private_storage() {
		@:privateAccess stream.jid = 'hamlet@shakespeare.lit/denmark';
		// https://xmpp.org/extensions/xep-0049.html#protocol
		final prefs = XML.fromString('<exodus xmlns="exodus:prefs"><defaultnick>Hamlet</defaultnick></exodus>');
		var response:Response<xmpp.IQ.Payload> = null;
		var iq = xmpp.PrivateStorage.setPrivateStorage(stream, prefs, r -> response = r);
		equals('set', lastSent().get('type'));
		isNull(lastSent().get('to'));
		equals(1, lastSent().firstElement.elements.length);
		stream.recv('<iq type="result" from="hamlet@shakespeare.lit/denmark" to="hamlet@shakespeare.lit/denmark" id="${iq.id}"/>');
		isTrue(response.ok());

		xmpp.PrivateStorage.setPrivateStorage(stream, [XML.fromString('<a xmlns="x:y"/>'), XML.fromString('<b xmlns="x:y"/>')], r -> {});
		equals(2, lastSent().firstElement.elements.length);

		iq = xmpp.PrivateStorage.getPrivateStorage(stream, XML.fromString('<exodus xmlns="exodus:prefs"/>'), r -> response = r);
		equals('get', lastSent().get('type'));
		stream.recv('<iq type="result" from="hamlet@shakespeare.lit/denmark" to="hamlet@shakespeare.lit/denmark" id="${iq.id}"><query xmlns="jabber:iq:private"><exodus xmlns="exodus:prefs"><defaultnick>Hamlet</defaultnick></exodus></query></iq>');
		final data = xmpp.PrivateStorage.getData(response.payload);
		equals('exodus', data.name);
		equals('Hamlet', data.firstElement.text);
		isNull(xmpp.PrivateStorage.getData(null));
	}
}
