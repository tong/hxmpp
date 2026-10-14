import utest.Assert.*;
import xmpp.IQ;
import xmpp.XML;

using xmpp.HttpFileUpload;

class TestHttpFileUpload extends StreamTest {
	function test_http_upload_slot() {
		final stream = new xmpp.client.Stream('example.com');
		final sent = new Array<String>();
		stream.output = str -> sent.push(str);
		final req:IQ = '<iq type="get" id="s1" from="romeo@example.net/orchard"><request xmlns="urn:xmpp:http:upload:0" filename="a.jpg" size="23456"/></iq>';
		stream.sendHttpUploadSlot(req, 'https://upload.example.com/put', 'https://download.example.com/get', ['Authorization' => 'Basic Base64String==']);
		final iq = XML.fromString(sent[0]);
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

	function test_http_upload_request() {
		xmpp.HttpFileUpload.requestHttpUploadSlot(stream, 'upload.montague.tld', 'très cool.jpg', 23456, 'image/jpeg', r -> {});
		var req = lastSent().firstElement;
		equals('upload.montague.tld', lastSent().get('to'));
		equals('get', lastSent().get('type'));
		equals('request', req.name);
		equals('très cool.jpg', req.get('filename'));
		equals('23456', req.get('size'));
		equals('image/jpeg', req.get('content-type'));
		equals(0, req.elements.length);

		// sizes above 2 GiB
		xmpp.HttpFileUpload.requestHttpUploadSlot(stream, 'upload.montague.tld', 'big.iso', 5000000000.0, r -> {});
		equals('5000000000', lastSent().firstElement.get('size'));

		xmpp.HttpFileUpload.requestHttpUploadSlot(stream, 'upload.montague.tld', 'avatar.png', 1000, Profile, r -> {});
		req = lastSent().firstElement;
		equals('profile', req.firstElement.name);
		equals(xmpp.HttpFileUpload.XMLNS_PURPOSE, req.firstElement.get('xmlns'));

		xmpp.HttpFileUpload.requestHttpUploadSlot(stream, 'upload.montague.tld', 'story.jpg', 1000, 'image/jpeg', Ephemeral(Date.fromTime(1781049600000.0)), r -> {});
		req = lastSent().firstElement;
		equals('ephemeral', req.firstElement.name);
		equals('2026-06-10T00:00:00Z', req.firstElement.get('expire-before'));
	}

	function test_http_upload_slot_parse() {
		// https://xmpp.org/extensions/xep-0363.html#request
		final slot = xmpp.HttpFileUpload.parseSlot(XML.fromString('<slot xmlns="urn:xmpp:http:upload:0">
			<put url="https://upload.montague.tld/4a771ac1-f0b2-4a4a-9700-f2a26fa2bb67/tr%C3%A8s%20cool.jpg">
				<header name="Authorization">Basic Base64String==</header>
				<header name="Cookie">foo=bar; user=romeo</header>
				<header name="eXpires">Tue, 1 Jan 2030 00:00:00 GMT</header>
				<header name="X-Evil">injected</header>
				<header name="Cookie">second=1</header>
			</put>
			<get url="https://download.montague.tld/4a771ac1-f0b2-4a4a-9700-f2a26fa2bb67/tr%C3%A8s%20cool.jpg"/>
		</slot>'));
		equals('https://upload.montague.tld/4a771ac1-f0b2-4a4a-9700-f2a26fa2bb67/tr%C3%A8s%20cool.jpg', slot.put);
		equals('https://download.montague.tld/4a771ac1-f0b2-4a4a-9700-f2a26fa2bb67/tr%C3%A8s%20cool.jpg', slot.get);
		equals('Authorization,Cookie,eXpires,Cookie', [for (h in slot.headers) h.name].join(','));
		equals('second=1', slot.headers[3].value);

		// newlines are removed
		final slot = xmpp.HttpFileUpload.parseSlot(XML.fromString('<slot xmlns="urn:xmpp:http:upload:0"><put url="https://u"><header name="Cookie">a=1\r\nX-Evil: 1</header></put><get url="https://g"/></slot>'));
		equals('a=1X-Evil: 1', slot.headers[0].value);

		isNull(xmpp.HttpFileUpload.parseSlot(XML.fromString('<slot xmlns="urn:xmpp:http:upload:0"><put url="https://u"/></slot>')));
	}

	function test_http_upload_errors() {
		// https://xmpp.org/extensions/xep-0363.html#errors
		final iq:IQ = '<iq type="error" id="step_03"><error type="modify"><not-acceptable xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/><text xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">File too large. The maximum file size is 20000 bytes</text><file-too-large xmlns="urn:xmpp:http:upload:0"><max-file-size>20000</max-file-size></file-too-large></error></iq>';
		equals(20000.0, xmpp.HttpFileUpload.getMaxFileSize(iq.error));
		isNull(xmpp.HttpFileUpload.getRetry(iq.error));

		final iq:IQ = '<iq type="error" id="step_03"><error type="wait"><resource-constraint xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/><text xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">Quota reached. You can only upload 5 files in 5 minutes</text><retry xmlns="urn:xmpp:http:upload:0" stamp="2017-12-03T23:42:05Z"/></error></iq>';
		equals(1512344525000.0, xmpp.HttpFileUpload.getRetry(iq.error).getTime());
		isNull(xmpp.HttpFileUpload.getMaxFileSize(iq.error));

		isNull(xmpp.HttpFileUpload.getMaxFileSize(null));
		isNull(xmpp.HttpFileUpload.getRetry(new xmpp.Stanza.Error(cancel, not_allowed)));
	}
}
