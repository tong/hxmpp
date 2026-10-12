import utest.Assert.*;
import xmpp.Muc;
import xmpp.Response;
import xmpp.Stanza;
import xmpp.XML;

class TestMuc extends utest.Test {
	var stream:xmpp.client.Stream;
	var sent:Array<String>;
	var muc:Muc;

	function setup() {
		sent = [];
		stream = new xmpp.client.Stream('example.com');
		stream.output = str -> sent.push(str);
		stream.start(features -> {});
		stream.recv("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='abc' from='example.com' version='1.0'><stream:features></stream:features>");
		muc = new Muc(stream, 'muc.example.com', 'room');
	}

	function lastSent():XML
		return XML.fromString(sent[sent.length - 1]);

	function join(nick:String, ?password:String):{done:Bool, response:Null<Response<XML>>} {
		final r = {done: false, response: null};
		muc.join(nick, password, res -> {
			r.done = true;
			r.response = res;
		});
		return r;
	}

	function test_join() {
		final r = join('juliet');
		final p = lastSent();
		equals('presence', p.name);
		equals('room@muc.example.com/juliet', p.get('to'));
		equals(Muc.XMLNS, p.firstElement.get('xmlns'));
		equals(0, p.firstElement.elements.count());
		isFalse(r.done);
		stream.recv('<presence id="${p.get("id")}" from="room@muc.example.com/juliet"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="member" role="participant"/><status code="110"/></x></presence>');
		isTrue(r.done);
		isTrue(r.response.ok());
		equals('juliet', muc.nick);
		equals(member, muc.affiliation);
		equals(participant, muc.role);
		equals('room@muc.example.com/juliet', muc.jid.toString());
	}

	function test_join_password() {
		join('juliet', 'secret');
		equals('secret', lastSent().firstElement.elements.named('password')[0].text);
	}

	function test_join_assigned_nick() {
		join('juliet');
		final id = lastSent().get('id');
		stream.recv('<presence id="$id" from="room@muc.example.com/juliet2"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="participant"/><status code="110"/><status code="210"/></x></presence>');
		equals('juliet2', muc.nick);
	}

	function test_join_error() {
		final r = join('juliet');
		final id = lastSent().get('id');
		stream.recv('<presence id="$id" type="error" from="room@muc.example.com/juliet"><error type="cancel"><conflict xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></presence>');
		isTrue(r.done);
		isFalse(r.response.ok());
		equals(conflict, r.response.error.condition);
	}

	function test_say() {
		join('juliet');
		stream.recv('<presence id="${lastSent().get("id")}" from="room@muc.example.com/juliet"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="participant"/><status code="110"/></x></presence>');
		muc.say('hello');
		final m = lastSent();
		equals('room@muc.example.com', m.get('to'));
		equals('groupchat', m.get('type'));
		equals('hello', m.elements.named('body')[0].text);
	}

	function test_private_message() {
		muc.sendPrivateMessage('romeo', 'hi');
		final m = lastSent();
		equals('room@muc.example.com/romeo', m.get('to'));
		equals('chat', m.get('type'));
		equals('hi', m.elements.named('body')[0].text);
	}

	function test_change_subject() {
		muc.changeSubject('Topic');
		final m = lastSent();
		equals('room@muc.example.com', m.get('to'));
		equals('groupchat', m.get('type'));
		equals('Topic', m.elements.named('subject')[0].text);
		equals(0, m.elements.named('body').length);
	}

	function test_change_nick() {
		join('juliet');
		stream.recv('<presence id="${lastSent().get("id")}" from="room@muc.example.com/juliet"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="participant"/><status code="110"/></x></presence>');

		var done = false;
		var error:Null<xmpp.Stanza.Error> = null;
		muc.changeNick('jules', e -> {
			done = true;
			error = e;
		});
		equals('room@muc.example.com/jules', lastSent().get('to'));
		stream.recv('<presence id="${lastSent().get("id")}" type="error" from="room@muc.example.com/jules"><error type="cancel"><conflict xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></presence>');
		isTrue(done);
		equals(conflict, error.condition);
		equals('juliet', muc.nick);

		done = false;
		muc.changeNick('jules', e -> {
			done = true;
			error = e;
		});
		stream.recv('<presence id="${lastSent().get("id")}" from="room@muc.example.com/jules"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="participant"/><status code="110"/></x></presence>');
		isTrue(done);
		isNull(error);
		equals('jules', muc.nick);
	}

	function test_leave() {
		join('juliet');
		stream.recv('<presence id="${lastSent().get("id")}" from="room@muc.example.com/juliet"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="participant"/><status code="110"/></x></presence>');
		var left = false;
		muc.leave('bye', () -> left = true);
		final p = lastSent();
		equals('unavailable', p.get('type'));
		equals('room@muc.example.com/juliet', p.get('to'));
		stream.recv('<presence id="${p.get("id")}" type="unavailable" from="room@muc.example.com/juliet"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="none"/><status code="110"/></x></presence>');
		isTrue(left);
	}
}
