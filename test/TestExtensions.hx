import utest.Assert.*;
import xmpp.IQ;
import xmpp.Message;
import xmpp.XML;

using xmpp.HttpFileUpload;
using xmpp.LastMessageCorrection;

class TestExtensions extends utest.Test {
	function test_last_message_correction() {
		final m = new Message('romeo@example.net', 'fixed').correct('msg42');
		final replace = m.toXML().elements.named('replace')[0];
		equals(LastMessageCorrection.XMLNS, replace.get('xmlns'));
		equals('msg42', replace.get('id'));

		final m:Message = m.toString();
		equals('msg42', m.correction());
		isNull(new Message('romeo@example.net', 'hi').correction());
	}

	function test_http_upload_slot() {
		final stream = new xmpp.client.Stream('example.com');
		final sent = new Array<String>();
		stream.output = str -> sent.push(str);
		final req:IQ = '<iq type="get" id="s1" from="romeo@example.net/orchard"><request xmlns="urn:xmpp:http:upload:0" filename="a.jpg" size="23456"/></iq>';
		stream.sendHttpUploadSlot(req, 'https://upload.example.com/put', 'https://download.example.com/get', ['Authorization' => 'Basic Base64String==']);
		final iq = XML.parse(sent[0]).firstElement;
		equals('result', iq.get('type'));
		equals('romeo@example.net/orchard', iq.get('to'));
		final slot = iq.firstElement;
		final put = slot.elements.named('put')[0];
		equals('https://upload.example.com/put', put.get('url'));
		final header = put.elements.named('header')[0];
		equals('Authorization', header.get('name'));
		equals('Basic Base64String==', header.text);
		equals('https://download.example.com/get', slot.elements.named('get')[0].get('url'));
	}
}
