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

	function joined() {
		join('juliet');
		stream.recv('<presence id="${lastSent().get("id")}" from="room@muc.example.com/juliet"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="member" role="participant"/><status code="110"/></x></presence>');
	}

	function test_invite() {
		// https://xmpp.org/extensions/xep-0045.html#invite-mediated
		muc.invite('hecate@shakespeare.lit', 'Hey Hecate');
		var m = lastSent();
		equals('room@muc.example.com', m.get('to'));
		equals('normal', m.get('type'));
		final invite = m.firstElement.firstElement;
		equals(Muc.XMLNS_USER, m.firstElement.get('xmlns'));
		equals('invite', invite.name);
		equals('hecate@shakespeare.lit', invite.get('to'));
		equals('Hey Hecate', invite.firstElement.text);

		// https://xmpp.org/extensions/xep-0249.html
		muc.inviteDirect('hecate@shakespeare.lit', 'Hey Hecate', 'cauldronburn');
		m = lastSent();
		equals('hecate@shakespeare.lit', m.get('to'));
		equals('normal', m.get('type'));
		final x = m.firstElement;
		equals(Muc.XMLNS_CONFERENCE, x.get('xmlns'));
		equals('room@muc.example.com', x.get('jid'));
		equals('cauldronburn', x.get('password'));
		equals('Hey Hecate', x.get('reason'));
	}

	function test_get_invitation() {
		var i = Muc.getInvitation(xmpp.Message.fromString('<message from="coven@chat.shakespeare.lit" id="nzd143v8" to="hecate@shakespeare.lit"><x xmlns="http://jabber.org/protocol/muc#user"><invite from="crone1@shakespeare.lit/desktop"><reason>\n Hey Hecate, this is the place for all good witches!\n </reason></invite><password>cauldronburn</password></x></message>'));
		equals('coven@chat.shakespeare.lit', i.room);
		equals('crone1@shakespeare.lit/desktop', i.from);
		equals('Hey Hecate, this is the place for all good witches!', i.reason);
		equals('cauldronburn', i.password);

		i = Muc.getInvitation(xmpp.Message.fromString('<message from="crone1@shakespeare.lit/desktop" to="hecate@shakespeare.lit"><x xmlns="jabber:x:conference" jid="darkcave@macbeth.shakespeare.lit" password="cauldronburn" reason="Hey Hecate, this is the place for all good witches!"/></message>'));
		equals('darkcave@macbeth.shakespeare.lit', i.room);
		equals('crone1@shakespeare.lit/desktop', i.from);
		equals('cauldronburn', i.password);

		isNull(Muc.getInvitation(new xmpp.Message('a@b', 'hi')));
	}

	function test_occupant_presence() {
		joined();
		final presences = new Array<String>();
		muc.onPresence = p -> presences.push(p.from);
		muc.handlePresence(xmpp.Presence.fromString('<presence from="room@muc.example.com/romeo"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="participant"/></x></presence>'));
		muc.handlePresence(xmpp.Presence.fromString('<presence from="other@muc.example.com/romeo"/>'));
		muc.handlePresence(xmpp.Presence.fromString('<presence/>'));
		equals('room@muc.example.com/romeo', presences.join(','));
	}

	function test_leave_reasons() {
		var left:LeaveReason = null;
		var text:String = null;
		function leave(xml:String) {
			setup();
			joined();
			left = null;
			text = null;
			muc.onLeave = (r, ?t) -> {
				left = r;
				text = t;
			}
			muc.handlePresence(xmpp.Presence.fromString(xml));
		}

		// https://xmpp.org/extensions/xep-0045.html#kick
		leave('<presence from="room@muc.example.com/juliet" type="unavailable"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="none"><actor nick="Fluellen"/><reason>Avaunt, you cullion!</reason></item><status code="110"/><status code="307"/></x></presence>');
		isTrue(left.match(Kicked));
		equals('Avaunt, you cullion!', text);
		equals(xmpp.Muc.Role.none, muc.role);

		leave('<presence from="room@muc.example.com/juliet" type="unavailable"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="outcast" role="none"/><status code="110"/><status code="301"/></x></presence>');
		isTrue(left.match(Banned));

		// https://xmpp.org/extensions/xep-0045.html#service-error-kick (also carries 307)
		leave('<presence from="room@muc.example.com/juliet" type="unavailable"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="none"/><status code="110"/><status code="307"/><status code="333"/></x></presence>');
		isTrue(left.match(ServiceError));

		// https://xmpp.org/extensions/xep-0045.html#destroyroom (no status 110)
		leave('<presence from="room@muc.example.com/juliet" type="unavailable"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="none"/><destroy jid="coven@chat.shakespeare.lit"><reason>Macbeth doth come.</reason></destroy></x></presence>');
		switch left {
			case Destroyed(alternate): equals('coven@chat.shakespeare.lit', alternate);
			case _: fail('expected Destroyed');
		}
		equals('Macbeth doth come.', text);

		leave('<presence from="room@muc.example.com/juliet" type="unavailable"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="member" role="none"/><status code="110"/></x></presence>');
		isTrue(left.match(Left));

		// other occupants leaving is no own leave
		leave('<presence from="room@muc.example.com/romeo" type="unavailable"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="none"/><status code="307"/></x></presence>');
		isNull(left);
	}

	function test_nick_changed_by_room() {
		joined();
		var changed:String = null;
		muc.onNick = n -> changed = n;
		muc.handlePresence(xmpp.Presence.fromString('<presence from="room@muc.example.com/juliet" type="unavailable"><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="member" role="participant" nick="jules"/><status code="110"/><status code="303"/></x></presence>'));
		equals('jules', changed);
		equals('jules', muc.nick);
	}

	function test_messages() {
		joined();
		final events = new Array<String>();
		muc.onMessage = m -> events.push('message:${m.body}');
		muc.onPrivateMessage = m -> events.push('private:${m.body}');
		muc.onSubject = s -> events.push('subject:$s');
		muc.onError = e -> events.push('error:${e.condition}');
		muc.handleMessage(xmpp.Message.fromString('<message from="room@muc.example.com/romeo" type="groupchat"><body>hi</body></message>'));
		muc.handleMessage(xmpp.Message.fromString('<message from="room@muc.example.com/romeo" type="groupchat"><subject>Topic</subject></message>'));
		muc.handleMessage(xmpp.Message.fromString('<message from="room@muc.example.com/romeo" type="groupchat"><subject/></message>'));
		muc.handleMessage(xmpp.Message.fromString('<message from="room@muc.example.com/romeo" type="chat"><body>psst</body></message>'));
		muc.handleMessage(xmpp.Message.fromString('<message from="room@muc.example.com" type="error"><error type="modify"><not-acceptable xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></message>'));
		muc.handleMessage(xmpp.Message.fromString('<message from="other@muc.example.com/x" type="groupchat"><body>no</body></message>'));
		muc.handleMessage(xmpp.Message.fromString('<message type="groupchat"><body>no</body></message>'));
		equals('message:hi,subject:Topic,subject:,private:psst,error:not-acceptable', events.join(','));
		equals('', muc.subject);
	}
}
