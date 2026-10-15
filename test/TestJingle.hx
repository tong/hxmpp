import haxe.io.Bytes;
import utest.Assert.*;
import xmpp.Jingle;
import xmpp.JingleFileTransfer;
import xmpp.JingleIBB;
import xmpp.JingleS5B;
import xmpp.JingleS5BNetwork;
import xmpp.XML;

/**
	Two client streams connected through a fake server, which sets the `from` of the stanzas.
**/
private class Peers {
	public final romeo:xmpp.client.Stream;
	public final juliet:xmpp.client.Stream;
	public final log = new Array<{from:String, xml:XML}>();

	/** SOCKS5 proxy answering iq requests to its jid **/
	public var proxy:Null<FakeProxy>;

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
			if (proxy != null && xml.get('to') == proxy.jid) {
				final response = proxy.handle(xml);
				if (response != null)
					a.recv(response.toString());
				return;
			}
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
				JingleFileTransfer.receiveFile(session, {blockSize: maxBlockSize ?? 65535, onProgress: n -> r.progress.push(n)}, (reason, data) -> {
					r.receiver = reason;
					r.received = data;
				});
		}
		JingleFileTransfer.sendFile(romeo, JULIET, offer ?? {name: 'test.bin', mediaType: 'application/octet-stream'}, data, {blockSize: blockSize ?? 4096},
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

	// SOCKS5 bytestreams

	function test_s5b_transport() {
		// https://xmpp.org/extensions/xep-0260.html#protocol-initiate
		final info = JingleS5B.parseTransport(XML.fromString("<transport xmlns='urn:xmpp:jingle:transports:s5b:1' dstaddr='972b7bf47291ca609517f67f86b5081086052dad' mode='tcp' sid='vj3hs98y'>
			<candidate cid='hft54dqy' host='192.168.4.1' jid='romeo@montague.lit/orchard' port='5086' priority='8257636' type='direct'/>
			<candidate cid='hutr46fe' host='24.24.24.1' jid='romeo@montague.lit/orchard' port='5087' priority='8258636' type='direct'/>
			<candidate cid='xmdh4b7i' host='123.456.7.8' jid='streamer.shakespeare.lit' port='7625' priority='7878787' type='proxy'/>
			<candidate cid='invalid' host='1.2.3.4'/>
		</transport>"));
		equals('vj3hs98y', info.sid);
		equals('972b7bf47291ca609517f67f86b5081086052dad', info.dstaddr);
		equals('tcp', info.mode);
		equals(3, info.candidates.length);
		final c = info.candidates[2];
		equals('xmdh4b7i', c.cid);
		equals('123.456.7.8', c.host);
		equals('streamer.shakespeare.lit', c.jid);
		equals(7625, c.port);
		equals(7878787, c.priority);
		equals(JingleS5BCandidateType.proxy, c.type);
		isFalse(info.candidateError);
		same(c, JingleS5B.parseTransport(XML.create('transport').set('xmlns', JingleS5B.XMLNS).set('sid', 's').append(JingleS5B.createCandidate(c))).candidates[0]);

		// https://xmpp.org/extensions/xep-0260.html#protocol-negotiation
		final info = JingleS5B.parseTransport(XML.fromString("<transport xmlns='urn:xmpp:jingle:transports:s5b:1' sid='vj3hs98y'><candidate-used cid='hr65dqyd'/></transport>"));
		equals('hr65dqyd', info.candidateUsed);
		isTrue(JingleS5B.parseTransport(XML.fromString("<transport xmlns='urn:xmpp:jingle:transports:s5b:1' sid='vj3hs98y'><candidate-error/></transport>")).candidateError);
		equals('xmdh4b7i', JingleS5B.parseTransport(XML.fromString("<transport xmlns='urn:xmpp:jingle:transports:s5b:1' sid='vj3hs98y'><activated cid='xmdh4b7i'/></transport>")).activated);
		isTrue(JingleS5B.parseTransport(XML.fromString("<transport xmlns='urn:xmpp:jingle:transports:s5b:1' sid='vj3hs98y'><proxy-error/></transport>")).proxyError);
		isNull(JingleS5B.parseTransport(JingleIBB.createTransport('x')));

		equals('972b7bf47291ca609517f67f86b5081086052dad', JingleS5B.createDstaddr('vj3hs98y', ROMEO, JULIET));
		equals('1a12fb7bc625e55f3ed5b29a53dbe0e4aa7d80ba', JingleS5B.createDstaddr('vj3hs98y', JULIET, ROMEO));
		equals(8257536, JingleS5B.priority(direct));
		equals(8257636, JingleS5B.priority(direct, 100));
		equals(655360, JingleS5B.priority(proxy));
	}

	function test_socks5_handshake() {
		function pair() {
			final a = new FakeConnection();
			final b = new FakeConnection();
			a.peer = b;
			b.peer = a;
			return {client: a, server: b};
		}
		final addr = JingleS5B.createDstaddr('vj3hs98y', ROMEO, JULIET);
		var p = pair();
		var server:{error:String, addr:String, stream:JingleS5BStream} = null;
		var client:{error:String, stream:JingleS5BStream} = null;
		JingleS5B.socks5Accept(p.server, a -> a == addr, (e, a, s) -> server = {error: e, addr: a, stream: s});
		final written = [];
		final write = p.client.write;
		JingleS5B.socks5Connect(p.client, addr, (e, s) -> {
			client = {error: e, stream: s};
		});
		isNull(client.error);
		isNull(server.error);
		equals(addr, server.addr);
		// data in both directions, buffered until onData is set
		client.stream.write(Bytes.ofString('hello'));
		server.stream.write(Bytes.ofString('world'));
		final received = [];
		server.stream.onData = d -> received.push('server:' + d.toString());
		client.stream.onData = d -> received.push('client:' + d.toString());
		same(['server:hello', 'client:world'], received);
		var closed = false;
		server.stream.onClose = () -> closed = true;
		client.stream.close();
		isTrue(closed);

		// wrong address
		p = pair();
		JingleS5B.socks5Accept(p.server, a -> a == addr, (e, a, s) -> server = {error: e, addr: a, stream: s});
		JingleS5B.socks5Connect(p.client, JingleS5B.createDstaddr('other', ROMEO, JULIET), (e, s) -> client = {error: e, stream: s});
		equals('connection refused', server.error);
		equals('connection refused (5)', client.error);
		isNull(client.stream);
		isTrue(p.server.closed);

		// no acceptable authentication method
		p = pair();
		JingleS5B.socks5Accept(p.server, a -> true, (e, a, s) -> server = {error: e, addr: a, stream: s});
		p.client.write(Bytes.ofHex('050102'));
		equals('no acceptable authentication method', server.error);

		// request split into single bytes
		p = pair();
		server = null;
		JingleS5B.socks5Accept(p.server, a -> a == addr, (e, a, s) -> server = {error: e, addr: a, stream: s});
		final bytes = Bytes.ofHex('050100' + '0501000328' + Bytes.ofString(addr).toHex() + '0000');
		for (i in 0...bytes.length)
			p.client.write(bytes.sub(i, 1));
		isNull(server.error);
		equals(addr, server.addr);
	}

	function s5bTransfer(romeoConfig:Switchboard->JingleS5BConfig, julietConfig:Switchboard->Null<JingleS5BConfig>, ?fallback:Bool, ?proxy:Bool) {
		final board = new Switchboard();
		final p = new Peers();
		if (proxy)
			p.proxy = new FakeProxy(board);
		final romeo = new Jingle(p.romeo);
		final juliet = new Jingle(p.juliet);
		final data = Bytes.alloc(100000);
		for (i in 0...data.length)
			data.set(i, i * 13 & 0xFF);
		final r = {
			peers: p,
			proxy: p.proxy,
			data: data,
			sender: (null : JingleReasonInfo),
			receiver: (null : JingleReasonInfo),
			received: (null : Bytes)
		};
		final jc = julietConfig(board);
		juliet.onSessionInitiate = session -> JingleFileTransfer.receiveFile(session, (jc == null) ? null : {s5b: jc}, (reason, data) -> {
			r.receiver = reason;
			r.received = data;
		});
		JingleFileTransfer.sendFile(romeo, JULIET, {name: 'test.bin'}, data, {s5b: romeoConfig(board), fallback: fallback}, reason -> r.sender = reason);
		return r;
	}

	function transportInfo(p:Peers, from:String):Array<String> {
		final list = [];
		for (j in p.sent(from, 'jingle'))
			if (j.get('action') == 'transport-info')
				list.push(j.firstElement.firstElement.firstElement.name);
		return list;
	}

	function test_s5b_direct() {
		final r = s5bTransfer(b -> {network: new FakeNetwork(b, ['10.0.0.1'])}, b -> {network: new FakeNetwork(b, ['10.0.0.2', '10.0.0.3'])});
		equals(success, r.sender.condition);
		equals(success, r.receiver.condition);
		equals(0, r.data.compare(r.received));
		// no fallback
		equals(0, r.peers.sent(ROMEO, 'open').length);
		same(['candidate-used'], transportInfo(r.peers, ROMEO));
		same(['candidate-used'], transportInfo(r.peers, JULIET));
		// the offered candidates
		final initiate = r.peers.sent(ROMEO, 'jingle')[0];
		final offer = JingleS5B.parseTransport(initiate.firstElement.elements.named('transport')[0]);
		equals('tcp', offer.mode);
		isNull(offer.dstaddr);
		equals(1, offer.candidates.length);
		equals('10.0.0.1', offer.candidates[0].host);
		equals(ROMEO, offer.candidates[0].jid);
		equals(JingleS5BCandidateType.direct, offer.candidates[0].type);
		final accept = JingleS5B.parseTransport(r.peers.sent(JULIET, 'jingle')[0].firstElement.elements.named('transport')[0]);
		equals(offer.sid, accept.sid);
		isNull(accept.mode);
		equals(2, accept.candidates.length);
		isTrue(accept.candidates[0].priority > accept.candidates[1].priority);
	}

	function test_s5b_one_side() {
		// romeo offers no candidates, connects to juliet
		final r = s5bTransfer(b -> {network: new FakeNetwork(b, ['10.0.0.1']), direct: false}, b -> {network: new FakeNetwork(b, ['10.0.0.2'])});
		equals(success, r.receiver.condition);
		equals(0, r.data.compare(r.received));
		same(['candidate-used'], transportInfo(r.peers, ROMEO));
		same(['candidate-error'], transportInfo(r.peers, JULIET));

		// juliet can not connect
		final r = s5bTransfer(b -> {network: new FakeNetwork(b, ['10.0.0.1'])}, b -> {
			final n = new FakeNetwork(b, ['10.0.0.2']);
			n.offline = true;
			{network: n, direct: false};
		});
		equals(success, r.receiver.condition);
		equals(0, r.data.compare(r.received));
		same(['candidate-error'], transportInfo(r.peers, JULIET));
	}

	function test_s5b_fallback() {
		function offline(b:Switchboard, host:String):JingleS5BConfig {
			final n = new FakeNetwork(b, [host]);
			n.offline = true;
			return {network: n, direct: false};
		}
		// no connection: in-band bytestreams
		final r = s5bTransfer(b -> offline(b, '10.0.0.1'), b -> offline(b, '10.0.0.2'));
		equals(success, r.sender.condition);
		equals(success, r.receiver.condition);
		equals(0, r.data.compare(r.received));
		same(['candidate-error'], transportInfo(r.peers, ROMEO));
		same(['candidate-error'], transportInfo(r.peers, JULIET));
		final actions = [for (j in r.peers.sent(ROMEO, 'jingle')) j.get('action')];
		isTrue(actions.contains('transport-replace'));
		equals('transport-accept', [for (j in r.peers.sent(JULIET, 'jingle')) j.get('action')].filter(a -> a == 'transport-accept')[0]);
		isTrue(r.peers.sent(ROMEO, 'open').length == 1);

		// the receiver has no network
		final r = s5bTransfer(b -> {network: new FakeNetwork(b, ['10.0.0.1']), direct: false}, b -> null);
		equals(success, r.receiver.condition);
		equals(0, r.data.compare(r.received));
		isTrue(r.peers.sent(ROMEO, 'open').length == 1);

		// without fallback
		final r = s5bTransfer(b -> offline(b, '10.0.0.1'), b -> offline(b, '10.0.0.2'), false);
		equals(connectivity_error, r.sender.condition);
		equals(connectivity_error, r.receiver.condition);
		isNull(r.received);
	}

	function test_s5b_proxy() {
		// juliet connects to romeo's proxy, romeo activates it
		final r = s5bTransfer(b -> {network: new FakeNetwork(b, ['10.0.0.1']), direct: false, proxies: [{jid: 'proxy.lit', host: '10.0.0.100', port: 7777}]},
			b -> {network: new FakeNetwork(b, ['10.0.0.2']), direct: false}, null, true);
		equals(success, r.sender.condition);
		equals(success, r.receiver.condition);
		equals(0, r.data.compare(r.received));
		same(['candidate-error', 'activated'], transportInfo(r.peers, ROMEO));
		same(['candidate-used'], transportInfo(r.peers, JULIET));
		final offer = JingleS5B.parseTransport(r.peers.sent(ROMEO, 'jingle')[0].firstElement.elements.named('transport')[0]);
		equals(JingleS5B.createDstaddr(offer.sid, ROMEO, JULIET), offer.dstaddr);
		equals(JingleS5BCandidateType.proxy, offer.candidates[0].type);
		equals('proxy.lit', offer.candidates[0].jid);
		same([offer.dstaddr], r.proxy.activations);
		final activate = r.peers.log.filter(e -> e.xml.get('to') == 'proxy.lit')[0].xml.firstElement;
		equals(offer.sid, activate.get('sid'));
		equals(JULIET, activate.firstElement.text);

		// the proxy can not be reached by romeo: proxy-error, fallback
		final r = s5bTransfer(b -> {
			final n = new FakeNetwork(b, ['10.0.0.1']);
			n.blocked.push('10.0.0.100');
			{network: n, direct: false, proxies: [{jid: 'proxy.lit', host: '10.0.0.100', port: 7777}]};
		}, b -> {network: new FakeNetwork(b, ['10.0.0.2']), direct: false}, null, true);
		same(['candidate-error', 'proxy-error'], transportInfo(r.peers, ROMEO));
		equals(0, r.proxy.activations.length);
		equals(1, r.peers.sent(ROMEO, 'open').length);
		equals(success, r.sender.condition);
		equals(success, r.receiver.condition);
		equals(0, r.data.compare(r.received));

		// streamhost request
		final board = new Switchboard();
		final p = new Peers();
		p.proxy = new FakeProxy(board);
		var host:JingleS5BStreamhost = null;
		JingleS5B.requestStreamhost(p.romeo, 'proxy.lit', res -> host = JingleS5B.parseStreamhost(res.payload));
		same({jid: 'proxy.lit', host: '10.0.0.100', port: 7777}, host);
	}

	function test_s5b_nomination() {
		// both parties connect: on equal priority the initiator's choice (romeo connected to juliet's candidate)
		final board = new Switchboard();
		final p = new Peers();
		final romeo = new Jingle(p.romeo);
		final juliet = new Jingle(p.juliet);
		var r5:JingleS5B = null;
		var j5:JingleS5B = null;
		final received = [];
		function handle(s:JingleSession, t:() -> JingleS5B)
			s.onAction = (req, respond) -> {
				respond();
				t().handleInfo(req.contents[0].transport);
			}
		juliet.onSessionInitiate = s -> {
			final offered = s.contents[0].transport;
			j5 = new JingleS5B(s, 'c', initiator, {network: new FakeNetwork(board, ['10.0.0.2'])}, offered.get('sid'));
			handle(s, () -> j5);
			j5.onReady = stream -> {
				stream.onData = d -> received.push('juliet:' + d.toString());
				stream.write(Bytes.ofString('from juliet'));
			}
			j5.prepare(offered, () -> {
				s.accept([{creator: initiator, name: 'c', transport: j5.createTransport()}]);
				j5.start(offered);
			});
		}
		final session = romeo.createSession(JULIET);
		r5 = new JingleS5B(session, 'c', initiator, {network: new FakeNetwork(board, ['10.0.0.1'])});
		handle(session, () -> r5);
		r5.onReady = stream -> {
			stream.onData = d -> received.push('romeo:' + d.toString());
			stream.write(Bytes.ofString('from romeo'));
		}
		session.onAccept = c -> r5.start(c[0].transport);
		r5.prepare(null, () -> session.initiate([{creator: initiator, name: 'c', transport: r5.createTransport()}]));

		notNull(r5.nominated);
		equals(r5.nominated.cid, j5.nominated.cid);
		equals('10.0.0.2', r5.nominated.host);
		received.sort((a, b) -> a < b ? -1 : 1);
		same(['juliet:from romeo', 'romeo:from juliet'], received);
		same(['candidate-used'], transportInfo(p, ROMEO));
		same(['candidate-used'], transportInfo(p, JULIET));
		r5.close();
		j5.close();
	}
}

/**
	In-memory network: listeners by host and port.
**/
private class Switchboard {
	public final listeners = new Map<String, JingleS5BConnection->Void>();
	public var nextPort = 7000;

	public function new() {}

	public function connect(host:String, port:Int):Null<FakeConnection> {
		final listener = listeners.get('$host:$port');
		if (listener == null)
			return null;
		final a = new FakeConnection();
		final b = new FakeConnection();
		a.peer = b;
		b.peer = a;
		// the accepting side handles the connection first
		listener(b);
		return a;
	}
}

private class FakeNetwork implements JingleS5BNetwork {
	final board:Switchboard;
	final hosts:Array<String>;

	/** Outgoing connections fail **/
	public var offline = false;

	/** Outgoing connections to these hosts fail **/
	public var blocked = new Array<String>();

	public function new(board:Switchboard, hosts:Array<String>) {
		this.board = board;
		this.hosts = hosts;
	}

	public function connect(host:String, port:Int, callback:(error:Null<String>, connection:Null<JingleS5BConnection>) -> Void) {
		final c = (offline || blocked.contains(host)) ? null : board.connect(host, port);
		callback((c == null) ? 'connection refused' : null, c);
	}

	public function listen(onConnection:JingleS5BConnection->Void, callback:(error:Null<String>, port:Int) -> Void):() -> Void {
		final port = board.nextPort++;
		for (h in hosts)
			board.listeners.set('$h:$port', onConnection);
		callback(null, port);
		return () -> for (h in hosts) board.listeners.remove('$h:$port');
	}

	public function addresses()
		return hosts;
}

private class FakeConnection implements JingleS5BConnection {
	public var onData:Bytes->Void = data -> {};
	public var onClose:() -> Void = () -> {};
	public var peer:Null<FakeConnection>;
	public var closed(default, null) = false;

	public function new() {}

	public function write(data:Bytes)
		if (!closed && peer != null && !peer.closed)
			peer.onData(data.sub(0, data.length));

	public function close() {
		if (closed)
			return;
		closed = true;
		onClose();
		if (peer != null)
			peer.close();
	}
}

/**
	SOCKS5 bytestreams proxy: relays the two connections requesting the same address once activated.
**/
private class FakeProxy {
	public final jid:String;
	public final host = '10.0.0.100';
	public final port = 7777;
	public final requests = new Map<String, Array<JingleS5BStream>>();
	public final activations = new Array<String>();

	public function new(board:Switchboard, jid = 'proxy.lit') {
		this.jid = jid;
		board.listeners.set('$host:$port', connection -> JingleS5B.socks5Accept(connection, addr -> true, (error, addr, stream) -> {
			if (error == null) {
				requests[addr] ??= [];
				requests[addr].push(stream);
			}
		}));
	}

	public function handle(iq:XML):Null<XML> {
		final query = iq.firstElement;
		final result = XML.create('iq').set('type', 'result').set('id', iq.get('id')).set('from', jid).set('to', iq.get('from'));
		final activate = (query == null) ? null : query.elements.named('activate')[0];
		if (activate == null)
			return result.append(XML.create('query').set('xmlns', JingleS5B.XMLNS_BYTESTREAMS)
				.append(XML.create('streamhost').set('jid', jid).set('host', host).set('port', Std.string(port))));
		final addr = JingleS5B.createDstaddr(query.get('sid'), iq.get('from'), activate.text);
		final streams = requests.get(addr);
		if (streams == null || streams.length != 2)
			return result.set('type', 'error').append(new xmpp.Stanza.Error(cancel, item_not_found).toXML());
		activations.push(addr);
		streams[0].onData = data -> streams[1].write(data);
		streams[1].onData = data -> streams[0].write(data);
		return result;
	}
}
