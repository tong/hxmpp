import haxe.io.Bytes;
import utest.Assert.*;
import xmpp.Jingle;
import xmpp.XML;

/**
	Two client streams connected through a fake server, which sets the `from` of the stanzas.
**/
private class Peers {
	public final romeo:xmpp.client.Stream;
	public final juliet:xmpp.client.Stream;
	public final log = new Array<{from:String, xml:XML}>();

	public function new() {
		romeo = connect('romeo@montague.lit/orchard');
		juliet = connect('juliet@capulet.lit/balcony');
		pipe(romeo, juliet);
		pipe(juliet, romeo);
	}

	static function connect(jid:String):xmpp.client.Stream {
		final stream = new xmpp.client.Stream(jid.split('@')[1].split('/')[0]);
		stream.output = str -> {};
		stream.start(f -> {});
		stream.recv("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='abc' version='1.0'><stream:features></stream:features>");
		@:privateAccess stream.jid = jid;
		return stream;
	}

	function pipe(a:xmpp.client.Stream, b:xmpp.client.Stream) {
		a.output = str -> {
			final xml = XML.fromString(str);
			xml.set('from', a.jid);
			log.push({from: a.jid, xml: xml});
			b.recv(xml.toString());
		}
	}

	/** Sends `xml` to `stream` from `from` **/
	public function inject(stream:xmpp.client.Stream, from:String, xml:String):XML {
		final responses = [];
		final output = stream.output;
		stream.output = str -> responses.push(XML.fromString(str));
		final x = XML.fromString(xml);
		x.set('from', from);
		stream.recv(x.toString());
		stream.output = output;
		return responses[0];
	}

	public function sent(from:String, name:String):Array<XML>
		return [for (e in log) if (e.from == from && e.xml.firstElement != null && e.xml.firstElement.name == name) e.xml.firstElement];
}

class TestJingle extends utest.Test {
	static inline var ROMEO = 'romeo@montague.lit/orchard';
	static inline var JULIET = 'juliet@capulet.lit/balcony';

	function errors(iq:XML):Array<String> {
		final e = iq.elements.named('error')[0];
		return (e == null) ? [] : [for (c in e.elements) c.name];
	}

	function test_parse() {
		// https://xmpp.org/extensions/xep-0166.html#protocol-initiate
		final req = Jingle.parse(XML.fromString("<jingle xmlns='urn:xmpp:jingle:1' action='session-initiate' initiator='romeo@montague.lit/orchard' sid='a73sjjvkla37jfea'>
			<content creator='initiator' name='this-is-a-stub'>
				<description xmlns='urn:xmpp:jingle:apps:stub:0'/>
				<transport xmlns='urn:xmpp:jingle:transports:stub:0'/>
			</content>
		</jingle>"));
		equals(session_initiate, req.action);
		equals('a73sjjvkla37jfea', req.sid);
		equals(ROMEO, req.initiator);
		equals(1, req.contents.length);
		final c = req.contents[0];
		equals(JingleCreator.initiator, c.creator);
		equals('this-is-a-stub', c.name);
		isNull(c.senders);
		equals('urn:xmpp:jingle:apps:stub:0', c.description.get('xmlns'));
		equals('urn:xmpp:jingle:transports:stub:0', c.transport.get('xmlns'));

		// https://xmpp.org/extensions/xep-0166.html#def-reason
		final req = Jingle.parse(XML.fromString("<jingle xmlns='urn:xmpp:jingle:1' action='session-terminate' sid='a73sjjvkla37jfea'>
			<reason><alternative-session><sid>b84tkkwlmb48kgfb</sid></alternative-session><text>Use the other one</text><app xmlns='urn:example'/></reason>
		</jingle>"));
		equals(alternative_session, req.reason.condition);
		equals('b84tkkwlmb48kgfb', req.reason.sid);
		equals('Use the other one', req.reason.text);
		equals(1, req.reason.payload.length);

		isNull(Jingle.parse(XML.fromString("<jingle xmlns='urn:xmpp:jingle:1' action='session-initiate'/>")));
		isNull(Jingle.parse(XML.fromString("<jingle xmlns='urn:xmpp:jingle:1' action='jump' sid='x'/>")));

		final reason = Jingle.createReason({condition: alternative_session, sid: 'b84', text: 'other'});
		equals('alternative-session', reason.firstElement.name);
		equals('b84', reason.firstElement.firstElement.text);
		equals('other', reason.elements.named('text')[0].text);
	}

	function test_session() {
		final p = new Peers();
		final romeo = new Jingle(p.romeo);
		final juliet = new Jingle(p.juliet);
		var incoming:JingleSession = null;
		juliet.onSessionInitiate = s -> incoming = s;

		final content:JingleContent = {
			creator: initiator,
			name: 'stub',
			description: XML.create('description').set('xmlns', 'urn:example'),
			transport: XML.create('transport').set('xmlns', 'urn:example:transport')
		};
		var acked = false;
		final session = romeo.initiate(JULIET, [content], res -> acked = res.ok());
		isTrue(acked);
		equals(pending, session.state);
		isTrue(session.isInitiator);
		final initiate = p.sent(ROMEO, 'jingle')[0];
		equals('session-initiate', initiate.get('action'));
		equals(ROMEO, initiate.get('initiator'));

		notNull(incoming);
		equals(session.sid, incoming.sid);
		equals(ROMEO, incoming.peer);
		isFalse(incoming.isInitiator);
		equals('stub', incoming.contents[0].name);
		equals(incoming, juliet.getSession(ROMEO, session.sid));

		var accepted:Array<JingleContent> = null;
		session.onAccept = c -> accepted = c;
		incoming.accept();
		equals(active, session.state);
		equals(active, incoming.state);
		equals('stub', accepted[0].name);
		equals(JULIET, p.sent(JULIET, 'jingle')[0].get('responder'));
		// accepting again does nothing
		isNull(incoming.accept());

		// ping
		var pong = false;
		session.info(res -> pong = res.ok());
		isTrue(pong);
		// unsupported info
		var error:xmpp.Stanza.Error = null;
		session.info([XML.create('ringing').set('xmlns', 'urn:example')], res -> error = res.error);
		equals(xmpp.Stanza.ErrorCondition.feature_not_implemented, error.condition);
		equals('unsupported-info', error.app.condition);
		incoming.onInfo = payload -> payload[0].name == 'ringing';
		session.info([XML.create('ringing').set('xmlns', 'urn:example')], res -> error = res.error);
		isNull(error);

		// other actions
		session.send(transport_info, [content], res -> error = res.error);
		equals(xmpp.Stanza.ErrorCondition.feature_not_implemented, error.condition);

		var reasons = [];
		session.onTerminate = r -> reasons.push('romeo:' + r.condition);
		incoming.onTerminate = r -> reasons.push('juliet:' + r.condition + ':' + r.text);
		incoming.terminate(decline, 'not now');
		equals(ended, session.state);
		equals(ended, incoming.state);
		reasons.sort((a, b) -> a < b ? -1 : 1);
		same(['juliet:decline:not now', 'romeo:decline'], reasons);
		isNull(juliet.getSession(ROMEO, session.sid));
		isNull(romeo.getSession(JULIET, session.sid));
		isNull(incoming.terminate());
	}

	function test_errors() {
		final p = new Peers();
		final romeo = new Jingle(p.romeo);
		final juliet = new Jingle(p.juliet);
		// by default sessions are not supported
		final session = romeo.initiate(JULIET, [{creator: initiator, name: 'x'}]);
		equals(ended, session.state);
		equals(unsupported_applications, session.reason.condition);

		// peer without jingle support
		final q = new Peers();
		var reason:JingleReasonInfo = null;
		final s = new Jingle(q.romeo).createSession(JULIET);
		s.onTerminate = r -> reason = r;
		s.initiate([{creator: initiator, name: 'x'}]);
		equals(ended, s.state);
		equals(general_error, reason.condition);
		equals('service-unavailable', reason.text);
		isNull(s.initiate([{creator: initiator, name: 'x'}]));

		juliet.onSessionInitiate = s -> {};
		final session = romeo.initiate(JULIET, [{creator: initiator, name: 'x'}], 'sid1');

		// unknown session
		var iq = p.inject(p.juliet, ROMEO, "<iq type='set' id='e1'><jingle xmlns='urn:xmpp:jingle:1' action='session-info' sid='unknown'/></iq>");
		same(['item-not-found', 'unknown-session'], errors(iq));
		// session of another entity
		iq = p.inject(p.juliet, 'mallory@evil.lit/x', "<iq type='set' id='e2'><jingle xmlns='urn:xmpp:jingle:1' action='session-terminate' sid='sid1'/></iq>");
		same(['item-not-found', 'unknown-session'], errors(iq));
		equals(pending, juliet.getSession(ROMEO, 'sid1').state);
		// session-initiate of an existing session
		iq = p.inject(p.juliet, ROMEO, "<iq type='set' id='e3'><jingle xmlns='urn:xmpp:jingle:1' action='session-initiate' sid='sid1'><content creator='initiator' name='x'/></jingle></iq>");
		same(['unexpected-request', 'out-of-order'], errors(iq));
		// session-accept sent to the responder
		iq = p.inject(p.juliet, ROMEO, "<iq type='set' id='e4'><jingle xmlns='urn:xmpp:jingle:1' action='session-accept' sid='sid1'/></iq>");
		same(['unexpected-request', 'out-of-order'], errors(iq));
		// invalid requests
		iq = p.inject(p.juliet, ROMEO, "<iq type='set' id='e5'><jingle xmlns='urn:xmpp:jingle:1' action='session-info'/></iq>");
		same(['bad-request'], errors(iq));
		iq = p.inject(p.juliet, ROMEO, "<iq type='set' id='e6'><jingle xmlns='urn:xmpp:jingle:1' action='session-initiate' sid='sid2'/></iq>");
		same(['bad-request'], errors(iq));
		iq = p.inject(p.juliet, ROMEO, "<iq type='get' id='e7'><jingle xmlns='urn:xmpp:jingle:1' action='session-info' sid='sid1'/></iq>");
		same(['bad-request'], errors(iq));
		equals(pending, session.state);
	}

	function test_file_description() {
		// https://xmpp.org/extensions/xep-0234.html#requesting
		final file = JingleFileTransfer.parseDescription(XML.fromString("<description xmlns='urn:xmpp:jingle:apps:file-transfer:5'>
			<file>
				<date>1969-07-21T02:56:15Z</date>
				<desc>This is a test. If this were a real file...</desc>
				<media-type>text/plain</media-type>
				<name>test.txt</name>
				<range/>
				<size>6144</size>
				<hash xmlns='urn:xmpp:hashes:2' algo='sha-1'>w0mcJylzCn+AfvuGdqkty2+KP48=</hash>
			</file>
		</description>"));
		equals('1969-07-21T02:56:15Z', file.date);
		equals('This is a test. If this were a real file...', file.desc);
		equals('text/plain', file.mediaType);
		equals('test.txt', file.name);
		equals(6144.0, file.size);
		notNull(file.range);
		isNull(file.range.offset);
		equals(1, file.hashes.length);
		equals('sha-1', file.hashes[0].algo);
		equals('w0mcJylzCn+AfvuGdqkty2+KP48=', file.hashes[0].value);

		final xml = JingleFileTransfer.createDescription(file);
		equals(JingleFileTransfer.XMLNS, xml.get('xmlns'));
		final f = xml.firstElement;
		equals('6144', f.elements.named('size')[0].text);
		equals(JingleFileTransfer.XMLNS_HASHES, f.elements.named('hash')[0].get('xmlns'));
		same(file, JingleFileTransfer.parseDescription(xml));
		equals('5000000000', JingleFileTransfer.createFile({size: 5000000000}).firstElement.text);
		isNull(JingleFileTransfer.parseDescription(XML.fromString("<description xmlns='urn:example'/>")));

		// https://xmpp.org/extensions/xep-0300.html
		final data = Bytes.ofString('hello');
		final h = JingleFileTransfer.hash(data);
		equals('sha-256', h.algo);
		equals('LPJNul+wow4m6DsqxbninhsWHlwfp0JecwQzYpOLmCQ=', h.value);
		equals('qvTGHdzF6KLavt4PO0gs2a6pQ00=', JingleFileTransfer.hash(data, 'sha-1').value);
		isTrue(JingleFileTransfer.verify(data, [h]));
		isFalse(JingleFileTransfer.verify(Bytes.ofString('hellO'), [h]));
		isNull(JingleFileTransfer.verify(data, [{algo: 'md5', value: 'x'}]));
		isFalse(JingleFileTransfer.verify(data, [{algo: 'md5', value: 'x'}, {algo: 'sha-1', value: h.value}]));
	}

	function transfer(?offer:JingleFile, ?blockSize:Int, ?maxBlockSize:Int, size = 10000, ?receive:JingleSession->Void) {
		final p = new Peers();
		final romeo = new Jingle(p.romeo);
		final juliet = new Jingle(p.juliet);
		final data = Bytes.alloc(size);
		for (i in 0...size)
			data.set(i, i * 7 & 0xFF);
		final r = {
			peers: p,
			data: data,
			sender: (null : JingleReasonInfo),
			receiver: (null : JingleReasonInfo),
			received: (null : Bytes),
			offer: (null : JingleFile),
			progress: []
		};
		juliet.onSessionInitiate = session -> {
			r.offer = JingleFileTransfer.getFileOffer(session);
			if (receive != null)
				receive(session);
			else
				JingleFileTransfer.receiveFile(session, maxBlockSize ?? 65535, n -> r.progress.push(n), (reason, data) -> {
					r.receiver = reason;
					r.received = data;
				});
		}
		JingleFileTransfer.sendFile(romeo, JULIET, offer ?? {name: 'test.bin', mediaType: 'application/octet-stream'}, data, blockSize ?? 4096,
			reason -> r.sender = reason);
		return r;
	}

	function test_file_transfer() {
		final r = transfer(1024);
		equals('test.bin', r.offer.name);
		equals(10000.0, r.offer.size);
		equals('sha-256', r.offer.hashes[0].algo);
		equals(success, r.sender.condition);
		equals(success, r.receiver.condition);
		notNull(r.received);
		equals(0, r.data.compare(r.received));
		equals(10, r.progress.length);
		equals(10000, r.progress[9]);

		// https://xmpp.org/extensions/xep-0261.html
		final p = r.peers;
		final open = p.sent(ROMEO, 'open')[0];
		equals(JingleIBB.XMLNS_IBB, open.get('xmlns'));
		equals('1024', open.get('block-size'));
		equals('iq', open.get('stanza'));
		final data = p.sent(ROMEO, 'data');
		equals(10, data.length);
		equals('0', data[0].get('seq'));
		equals('9', data[9].get('seq'));
		equals(1, p.sent(ROMEO, 'close').length);
		final initiate = p.sent(ROMEO, 'jingle')[0];
		final content = initiate.firstElement;
		equals('initiator', content.get('senders'));
		equals(JingleIBB.XMLNS, content.elements.named('transport')[0].get('xmlns'));
		equals(open.get('sid'), content.elements.named('transport')[0].get('sid'));
		// the receiver confirms and terminates
		final juliet = p.sent(JULIET, 'jingle');
		equals('session-accept', juliet[0].get('action'));
		equals('session-info', juliet[1].get('action'));
		equals('received', juliet[1].firstElement.name);
		equals('session-terminate', juliet[2].get('action'));
		equals('success', juliet[2].firstElement.firstElement.name);
	}

	function test_file_transfer_block_size() {
		// the receiver lowers the block size
		final r = transfer(4096, 1000, 2500);
		equals(success, r.receiver.condition);
		equals('1000', r.peers.sent(JULIET, 'jingle')[0].firstElement.elements.named('transport')[0].get('block-size'));
		equals(3, r.peers.sent(ROMEO, 'data').length);
		equals(0, r.data.compare(r.received));

		// empty file
		final r = transfer(null, null, null, 0);
		equals(success, r.receiver.condition);
		equals(0, r.received.length);
	}

	function test_file_transfer_failures() {
		// declined
		final r = transfer(null, null, null, 100, session -> session.terminate(decline));
		equals(decline, r.sender.condition);
		equals(0, r.peers.sent(ROMEO, 'open').length);

		// hash mismatch
		final r = transfer({name: 'x', hashes: [{algo: 'sha-256', value: JingleFileTransfer.hash(Bytes.ofString('other')).value}]});
		equals(media_error, r.sender.condition);
		equals(media_error, r.receiver.condition);
		equals('hash mismatch', r.receiver.text);
		isNull(r.received);

		// size mismatch
		final r = transfer({name: 'x', size: 50});
		equals(failed_transport, r.receiver.condition);
		isNull(r.received);

		// unsupported transport
		final p = new Peers();
		final juliet = new Jingle(p.juliet);
		var reason:JingleReasonInfo = null;
		juliet.onSessionInitiate = s -> JingleFileTransfer.receiveFile(s, (r, d) -> reason = r);
		new Jingle(p.romeo).initiate(JULIET, [
			{
				creator: initiator,
				name: 'f',
				senders: initiator,
				description: JingleFileTransfer.createDescription({name: 'x'}),
				transport: XML.create('transport').set('xmlns', 'urn:xmpp:jingle:transports:s5b:1')
			}
		]);
		equals(unsupported_transports, reason.condition);

		// no file offer (a file request)
		final p = new Peers();
		final juliet = new Jingle(p.juliet);
		var offer:JingleFile = {};
		juliet.onSessionInitiate = s -> offer = JingleFileTransfer.getFileOffer(s);
		new Jingle(p.romeo).initiate(JULIET, [
			{
				creator: initiator,
				name: 'f',
				senders: responder,
				description: JingleFileTransfer.createDescription({name: 'x'}),
				transport: JingleIBB.createTransport('s')
			}
		]);
		isNull(offer);
	}

	function test_ibb_errors() {
		var session:JingleSession = null;
		final r = transfer(null, null, null, 100, s -> {
			session = s;
			JingleFileTransfer.receiveFile(s, (reason, data) -> {});
		});
		// the transfer is complete, the bytestream is unknown
		final p = r.peers;
		final sid = p.sent(ROMEO, 'open')[0].get('sid');
		var iq = p.inject(p.juliet, ROMEO, "<iq type='set' id='i1'><data xmlns='http://jabber.org/protocol/ibb' sid='" + sid + "' seq='0'>AAAA</data></iq>");
		same(['item-not-found'], errors(iq));

		// receive directly
		final p = new Peers();
		final juliet = new Jingle(p.juliet);
		var result:{error:xmpp.Stanza.Error, data:Bytes} = null;
		var incoming:JingleSession = null;
		juliet.onSessionInitiate = s -> incoming = s;
		new Jingle(p.romeo).initiate(JULIET, [{creator: initiator, name: 'x'}], 's1');
		JingleIBB.receive(incoming, 'ibb1', 16, 100, null, (e, d) -> result = {error: e, data: d});
		// another entity
		iq = p.inject(p.juliet, 'mallory@evil.lit/x', "<iq type='set' id='i2'><open xmlns='http://jabber.org/protocol/ibb' sid='ibb1' block-size='16'/></iq>");
		same(['item-not-found'], errors(iq));
		// data before open
		iq = p.inject(p.juliet, ROMEO, "<iq type='set' id='i3'><data xmlns='http://jabber.org/protocol/ibb' sid='ibb1' seq='0'>AAAA</data></iq>");
		same(['item-not-found'], errors(iq));
		// block size too large
		iq = p.inject(p.juliet, ROMEO, "<iq type='set' id='i4'><open xmlns='http://jabber.org/protocol/ibb' sid='ibb1' block-size='4096'/></iq>");
		same(['resource-constraint'], errors(iq));
		iq = p.inject(p.juliet, ROMEO, "<iq type='set' id='i5'><open xmlns='http://jabber.org/protocol/ibb' sid='ibb1' block-size='16' stanza='message'/></iq>");
		same(['feature-not-implemented'], errors(iq));
		iq = p.inject(p.juliet, ROMEO, "<iq type='set' id='i6'><open xmlns='http://jabber.org/protocol/ibb' sid='ibb1' block-size='16'/></iq>");
		equals('result', iq.get('type'));
		// base64 with whitespace
		iq = p.inject(p.juliet, ROMEO, "<iq type='set' id='i7'><data xmlns='http://jabber.org/protocol/ibb' sid='ibb1' seq='0'>aGVs\n  bG8=</data></iq>");
		equals('result', iq.get('type'));
		// out of order
		iq = p.inject(p.juliet, ROMEO, "<iq type='set' id='i8'><data xmlns='http://jabber.org/protocol/ibb' sid='ibb1' seq='5'>AAAA</data></iq>");
		equals('unexpected-request', errors(iq)[0]);
		equals(xmpp.Stanza.ErrorCondition.unexpected_request, result.error.condition);
		isNull(result.data);

		// successful close
		result = null;
		JingleIBB.receive(incoming, 'ibb2', 16, null, null, (e, d) -> result = {error: e, data: d});
		p.inject(p.juliet, ROMEO, "<iq type='set' id='i9'><open xmlns='http://jabber.org/protocol/ibb' sid='ibb2' block-size='16'/></iq>");
		p.inject(p.juliet, ROMEO, "<iq type='set' id='i10'><data xmlns='http://jabber.org/protocol/ibb' sid='ibb2' seq='0'>aGVsbG8=</data></iq>");
		iq = p.inject(p.juliet, ROMEO, "<iq type='set' id='i11'><data xmlns='http://jabber.org/protocol/ibb' sid='ibb2' seq='1'>" + haxe.crypto.Base64.encode(Bytes.alloc(17)) + "</data></iq>");
		same(['bad-request'], errors(iq));
	}
}
