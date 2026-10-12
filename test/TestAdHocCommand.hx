import utest.Assert.*;
import xmpp.AdHocCommand;
import xmpp.DataForm;
import xmpp.ServiceDiscovery;
import xmpp.XML;

using xmpp.AdHocCommand;

class TestAdHocCommand extends utest.Test {
	var stream:xmpp.client.Stream;
	var sent:Array<String>;

	function setup() {
		sent = [];
		stream = new xmpp.client.Stream('domain');
		stream.output = str -> sent.push(str);
		stream.start(features -> {});
		stream.recv("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='abc' from='domain' version='1.0'><stream:features></stream:features>");
		@:privateAccess stream.jid = 'responder@domain/res';
	}

	function lastSent():XML
		return XML.fromString(sent[sent.length - 1]);

	function request(xml:String):XML {
		stream.recv(xml);
		return lastSent();
	}

	function command(node:String, ?sessionid:String, ?action:String, ?from = 'requester@domain/res', ?payload = ''):XML {
		final s = (sessionid == null) ? '' : " sessionid='" + sessionid + "'";
		final a = (action == null) ? '' : " action='" + action + "'";
		return request("<iq type='set' id='exec' from='" + from + "' to='responder@domain/res'><command xmlns='http://jabber.org/protocol/commands' node='"
			+ node + "'" + s + a + ">" + payload + "</command></iq>");
	}

	function appCondition(iq:XML):Null<String> {
		final error = iq.elements.named('error')[0];
		final app = error.elements.first(e -> e.get('xmlns') == AdHocCommand.XMLNS);
		return (app == null) ? null : app.name;
	}

	function errorCondition(iq:XML):Null<String>
		return iq.elements.named('error')[0].elements.first(e -> e.get('xmlns') == 'urn:ietf:params:xml:ns:xmpp-stanzas').name;

	// requester

	function test_requests() {
		// https://xmpp.org/extensions/xep-0050.html#retrieve
		stream.requestCommandList('responder@domain', r -> {});
		final query = lastSent().firstElement;
		equals(ServiceDiscovery.XMLNS_ITEMS, query.get('xmlns'));
		equals(AdHocCommand.NODE, query.get('node'));
		equals('get', lastSent().get('type'));

		// https://xmpp.org/extensions/xep-0050.html#execute
		stream.execute('responder@domain', 'list', r -> {});
		final cmd = lastSent().firstElement;
		equals('set', lastSent().get('type'));
		equals('responder@domain', lastSent().get('to'));
		equals('command', cmd.name);
		equals(AdHocCommand.XMLNS, cmd.get('xmlns'));
		equals('list', cmd.get('node'));
		equals('execute', cmd.get('action'));
		isNull(cmd.get('sessionid'));

		// https://xmpp.org/extensions/xep-0050.html#execute-multiple
		final c:Command = {node: 'config', sessionid: 'config:20020923T213616Z-700', notes: [], payload: []};
		final form = new DataForm(submit);
		form.fields = [{variable: 'service', values: ['httpd']}];
		stream.continueCommand('responder@domain', c, form, r -> {});
		var cmd = lastSent().firstElement;
		equals('config', cmd.get('node'));
		equals('config:20020923T213616Z-700', cmd.get('sessionid'));
		isNull(cmd.get('action'));
		final x = cmd.firstElement;
		equals(DataForm.XMLNS, x.get('xmlns'));
		equals('submit', x.get('type'));

		stream.continueCommand('responder@domain', c, prev, r -> {});
		equals('prev', lastSent().firstElement.get('action'));
		equals(0, lastSent().firstElement.elements.length);

		// https://xmpp.org/extensions/xep-0050.html#cancel
		stream.cancelCommand('responder@domain', c, r -> {});
		cmd = lastSent().firstElement;
		equals('cancel', cmd.get('action'));
		equals('config:20020923T213616Z-700', cmd.get('sessionid'));
	}

	function test_parse() {
		// https://xmpp.org/extensions/xep-0050.html#execute-single
		var c = AdHocCommand.parseCommand(XML.fromString("<command xmlns='http://jabber.org/protocol/commands' sessionid='list:20020923T213616Z-700' node='list' status='completed' xml:lang='en-us'>
			<x xmlns='jabber:x:data' type='result'><title>Available Services</title><reported><field var='service' label='Service'/></reported><item><field var='service'><value>httpd</value></field></item></x>
		</command>"));
		equals('list', c.node);
		equals('list:20020923T213616Z-700', c.sessionid);
		equals(completed, c.status);
		equals('en-us', c.lang);
		isNull(c.actions);
		notNull(c.form);
		equals('Available Services', c.form.title);
		equals(0, c.notes.length);
		equals(0, c.payload.length);
		equals(complete, AdHocCommand.getDefaultAction(c));

		// https://xmpp.org/extensions/xep-0050.html#execute-multiple
		c = AdHocCommand.parseCommand(XML.fromString("<command xmlns='http://jabber.org/protocol/commands' sessionid='config:20020923T213616Z-700' node='config' status='executing'>
			<actions execute='next'><next/></actions>
			<x xmlns='jabber:x:data' type='form'><title>Configure Service</title><field var='service' label='Service' type='list-single'/></x>
			<x xmlns='jabber:x:oob'><url>http://example.com</url></x>
		</command>"));
		equals(executing, c.status);
		same([Actions.next], c.actions);
		equals(next, c.execute);
		equals(form, c.form.type);
		equals(1, c.payload.length);
		equals('jabber:x:oob', c.payload[0].get('xmlns'));
		equals(next, AdHocCommand.getDefaultAction(c));
		isTrue(AdHocCommand.isActionAllowed(c, next));
		isTrue(AdHocCommand.isActionAllowed(c, Action.execute));
		isTrue(AdHocCommand.isActionAllowed(c, cancel));
		isFalse(AdHocCommand.isActionAllowed(c, prev));
		isFalse(AdHocCommand.isActionAllowed(c, complete));

		// no execute attribute: next
		c = AdHocCommand.parseCommand(XML.fromString("<command xmlns='http://jabber.org/protocol/commands' node='a' status='executing'><actions><prev/><complete/></actions></command>"));
		equals(next, AdHocCommand.getDefaultAction(c));
		isFalse(AdHocCommand.isActionAllowed(c, Action.execute));
		isTrue(AdHocCommand.isActionAllowed(c, prev));

		// https://xmpp.org/extensions/xep-0050.html#execute-multiple (completed)
		c = AdHocCommand.parseCommand(XML.fromString("<command xmlns='http://jabber.org/protocol/commands' sessionid='config:20020923T213616Z-700' node='config' status='completed'><note type='info'>Service 'httpd' has been configured.</note><note>Default</note><note type='error'>Failed</note></command>"));
		equals(3, c.notes.length);
		equals(info, c.notes[0].type);
		equals("Service 'httpd' has been configured.", c.notes[0].text);
		equals(info, c.notes[1].type);
		equals(NoteType.error, c.notes[2].type);
		isNull(c.form);
	}

	// responder

	function config(?cancelled:Array<String>, ?requests:Array<CommandRequest>):CommandDefinition {
		return {
			node: 'config',
			name: 'Configure Service',
			execute: (req, respond) -> {
				if (requests != null)
					requests.push(req);
				switch req.action {
					case Action.execute:
						final form = new DataForm(form, 'Configure Service');
						form.fields = [{variable: 'service', type: list_single}];
						respond(Executing({form: form, actions: [next]}));
					case next:
						if (req.form == null || req.form.getValue('service') == null) {
							respond(Failed(new xmpp.Stanza.Error(modify, bad_request, null, {condition: AdHocCommand.BAD_PAYLOAD, xmlns: AdHocCommand.XMLNS})));
							return;
						}
						respond(Executing({form: new DataForm(form, 'Run modes'), actions: [prev, complete], execute: complete}));
					case prev:
						respond(Executing({form: new DataForm(form, 'Configure Service'), actions: [next]}));
					case complete:
						respond(Completed({notes: [{type: info, text: "Service 'httpd' has been configured."}]}));
					case _:
				}
			},
			cancel: (sid) -> if (cancelled != null) cancelled.push(sid)
		};
	}

	function test_handle_single_stage() {
		AdHocCommand.handleRequests(stream, [
			{
				node: 'list',
				name: 'List Service Configurations',
				execute: (req, respond) -> respond(Completed({form: new DataForm(result, 'Available Services')}))
			}
		]);
		final iq = command('list', null, 'execute');
		equals('result', iq.get('type'));
		equals('exec', iq.get('id'));
		final c = AdHocCommand.parseCommand(iq.firstElement);
		equals('list', c.node);
		equals(completed, c.status);
		notNull(c.sessionid);
		isTrue(StringTools.startsWith(c.sessionid, 'list:'));
		isNull(c.actions);
		equals(result, c.form.type);

		// each execution has a new session
		notEquals(c.sessionid, AdHocCommand.parseCommand(command('list').firstElement).sessionid);
		// the completed session has ended
		final iq = command('list', c.sessionid);
		equals('error', iq.get('type'));
		equals('not-allowed', errorCondition(iq));
		equals(AdHocCommand.SESSION_EXPIRED, appCondition(iq));
	}

	function test_handle_multiple_stages() {
		final requests = new Array<CommandRequest>();
		AdHocCommand.handleRequests(stream, [config(requests)]);

		var iq = command('config', null, 'execute');
		var c = AdHocCommand.parseCommand(iq.firstElement);
		equals(executing, c.status);
		same([Actions.next], c.actions);
		equals(next, c.execute);
		equals('Configure Service', c.form.title);
		final sid = c.sessionid;
		equals(Action.execute, requests[0].action);
		equals('requester@domain/res', requests[0].from);

		// missing payload
		iq = command('config', sid);
		equals('error', iq.get('type'));
		equals('bad-request', errorCondition(iq));
		equals(AdHocCommand.BAD_PAYLOAD, appCondition(iq));

		// not allowed in this stage
		iq = command('config', sid, 'complete');
		equals(AdHocCommand.BAD_ACTION, appCondition(iq));

		// submit without action: the default action (next)
		iq = command('config', sid, null, null, "<x xmlns='jabber:x:data' type='submit'><field var='service'><value>httpd</value></field></x>");
		c = AdHocCommand.parseCommand(iq.firstElement);
		equals(executing, c.status);
		equals(sid, c.sessionid);
		same([Actions.prev, Actions.complete], c.actions);
		equals(complete, c.execute);
		final last = requests[requests.length - 1];
		equals(next, last.action);
		equals('httpd', last.form.getValue('service'));
		equals(sid, last.sessionid);

		iq = command('config', sid, 'prev');
		equals('Configure Service', AdHocCommand.parseCommand(iq.firstElement).form.title);
		iq = command('config', sid, 'next', null, "<x xmlns='jabber:x:data' type='submit'><field var='service'><value>httpd</value></field></x>");
		iq = command('config', sid, 'execute');
		c = AdHocCommand.parseCommand(iq.firstElement);
		equals(completed, c.status);
		equals("Service 'httpd' has been configured.", c.notes[0].text);
		isNull(iq.firstElement.elements.named('actions')[0]);
		equals(complete, requests[requests.length - 1].action);
	}

	function test_handle_cancel() {
		final cancelled = [];
		AdHocCommand.handleRequests(stream, [config(cancelled)]);
		final sid = AdHocCommand.parseCommand(command('config').firstElement).sessionid;

		// https://xmpp.org/extensions/xep-0050.html#cancel
		var iq = command('config', sid, 'cancel');
		equals('result', iq.get('type'));
		final c = AdHocCommand.parseCommand(iq.firstElement);
		equals(canceled, c.status);
		equals(sid, c.sessionid);
		same([sid], cancelled);

		iq = command('config', sid, 'next');
		equals(AdHocCommand.SESSION_EXPIRED, appCondition(iq));
	}

	function test_handle_errors() {
		AdHocCommand.handleRequests(stream, [
			config(),
			{
				node: 'admin',
				name: 'Admin',
				allowed: jid -> jid != null && StringTools.startsWith(jid, 'admin@'),
				execute: (req, respond) -> respond(Completed({}))
			}
		]);
		var iq = command('unknown');
		equals('item-not-found', errorCondition(iq));

		iq = command('admin');
		equals('forbidden', errorCondition(iq));
		iq = command('admin', null, null, 'admin@domain/x');
		equals('result', iq.get('type'));

		iq = command('config', null, 'jump');
		equals('bad-request', errorCondition(iq));
		equals(AdHocCommand.MALFORMED_ACTION, appCondition(iq));

		iq = command('config', null, 'next');
		equals(AdHocCommand.BAD_ACTION, appCondition(iq));

		iq = command('config', 'unknown-session', 'next');
		equals('not-allowed', errorCondition(iq));
		equals(AdHocCommand.SESSION_EXPIRED, appCondition(iq));

		// session of another requester
		final sid = AdHocCommand.parseCommand(command('config').firstElement).sessionid;
		iq = command('config', sid, 'cancel', 'mallory@domain/x');
		equals('bad-request', errorCondition(iq));
		equals(AdHocCommand.BAD_SESSIONID, appCondition(iq));
		// requester jids are compared case-insensitively
		equals('result', command('config', sid, 'cancel', 'Requester@Domain/res').get('type'));

		iq = request("<iq type='get' id='g' from='requester@domain/res'><command xmlns='http://jabber.org/protocol/commands' node='config'/></iq>");
		equals('bad-request', errorCondition(iq));
	}

	function test_handle_disco() {
		final commands:Array<CommandDefinition> = [
			config(),
			{
				node: 'admin',
				name: 'Admin',
				allowed: jid -> false,
				execute: (req, respond) -> {}
			}
		];
		for (order in 0...2) {
			setup();
			if (order == 0) {
				ServiceDiscovery.handleRequests(stream, {category: 'client', type: 'bot'});
				AdHocCommand.handleRequests(stream, commands);
			} else {
				AdHocCommand.handleRequests(stream, commands);
				ServiceDiscovery.handleRequests(stream, {category: 'client', type: 'bot'});
			}

			// https://xmpp.org/extensions/xep-0050.html#disco
			var iq = request("<iq type='get' id='d1' from='requester@domain/res'><query xmlns='http://jabber.org/protocol/disco#info'/></iq>");
			isTrue(ServiceDiscovery.parseInfo(iq.firstElement).features.contains(AdHocCommand.XMLNS));

			// https://xmpp.org/extensions/xep-0050.html#retrieve
			iq = request("<iq type='get' id='d2' from='requester@domain/res' to='responder@domain/res'><query xmlns='http://jabber.org/protocol/disco#items' node='http://jabber.org/protocol/commands'/></iq>");
			equals('result', iq.get('type'));
			equals(AdHocCommand.NODE, iq.firstElement.get('node'));
			final items = ServiceDiscovery.parseItems(iq.firstElement);
			equals(1, items.length);
			equals('responder@domain/res', items[0].jid);
			equals('config', items[0].node);
			equals('Configure Service', items[0].name);

			// https://xmpp.org/extensions/xep-0050.html#retrieve (command info)
			iq = request("<iq type='get' id='d3' from='requester@domain/res'><query xmlns='http://jabber.org/protocol/disco#info' node='config'/></iq>");
			equals('config', iq.firstElement.get('node'));
			final info = ServiceDiscovery.parseInfo(iq.firstElement);
			equals('automation', info.identities[0].category);
			equals('command-node', info.identities[0].type);
			equals('Configure Service', info.identities[0].name);
			same([AdHocCommand.XMLNS, DataForm.XMLNS], info.features);

			iq = request("<iq type='get' id='d4' from='requester@domain/res'><query xmlns='http://jabber.org/protocol/disco#info' node='http://jabber.org/protocol/commands'/></iq>");
			equals('command-list', ServiceDiscovery.parseInfo(iq.firstElement).identities[0].type);

			iq = request("<iq type='get' id='d5' from='requester@domain/res'><query xmlns='http://jabber.org/protocol/disco#info' node='admin'/></iq>");
			equals('forbidden', errorCondition(iq));
			iq = request("<iq type='get' id='d6' from='requester@domain/res'><query xmlns='http://jabber.org/protocol/disco#info' node='other'/></iq>");
			equals('item-not-found', errorCondition(iq));
			iq = request("<iq type='get' id='d7' from='requester@domain/res'><query xmlns='http://jabber.org/protocol/disco#items'/></iq>");
			equals('result', iq.get('type'));
		}
	}
}
