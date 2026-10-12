package xmpp.component;

import haxe.crypto.Sha1;

using StringTools;

/**
	Stream of an external server component, authenticated with a shared secret (handshake).

		final stream = new xmpp.component.Stream('bot.example.com');
		stream.output = socket.write;
		stream.start(secret, (?error) -> if (error != null) trace(error.condition) else trace('ready'));

	Rules:
	- All stanzas sent by a component must have a `from` and a `to` address; stanzas without `from`
	  are sent from the component `host`, responses to requests from the address the request was sent to.
	- The domain of `from` addresses must be the component host, any user at the host may be used (e.g. `user@bot.example.com`).
	- The server trusts the component to write `from` addresses for its host, keep the secret safe.

	[XEP-0114: Jabber Component Protocol](https://xmpp.org/extensions/xep-0114.html)
**/
class Stream extends xmpp.Stream {
	/**
		Port of the jabberd 1.x component connection manager, servers use different defaults
		(Prosody and ejabberd: 5347) and it is usually configured per server.
	**/
	public static inline var PORT = 5275;

	/**
		Server (accept) component namespace.
	**/
	public static inline var XMLNS = 'jabber:component:accept';

	/**
		Component name, the full `host` if the stream was created without `domain`.
	**/
	public var name(default, null):String;

	/**
		Hostname of the component (`name.domain`, or `name` without `domain`), used as jid of the stream.
	**/
	public var host(default, null):String;

	/**
		Creates the stream of the component `name.domain`, or the component `name` if `domain` is `null`.
	**/
	public function new(name:String, ?domain:String, ?xmlns:String, ?lang:String) {
		final host = (domain == null) ? name : '$name.$domain';
		super(xmlns ?? XMLNS, domain ?? host, lang);
		this.name = name;
		this.host = host;
	}

	/**
		Opens the stream and authenticates with the shared `secret`.

		`handler` is called once: without error when the stream is ready, otherwise with the condition of the
		stream error (e.g. `not-authorized` for an invalid secret, `host-unknown` or `conflict` if the server does not
		serve the component) or `undefined-condition` if the stream was closed or the server sent unexpected data.
	**/
	public function start(secret:String, handler:(?error:xmpp.Stanza.Error) -> Void):Stream {
		reset();
		jid = host;
		var done = false;
		function finish(?error:xmpp.Stanza.Error) {
			if (done)
				return;
			done = true;
			if (error != null)
				ready = false;
			handler(error);
		}
		final _onEnd = onEnd;
		function fail(error:xmpp.Stanza.Error) {
			onEnd = _onEnd;
			input = str -> {};
			end();
			finish(error);
		}
		onEnd = () -> {
			onEnd = _onEnd;
			finish(new xmpp.Stanza.Error(cancel, undefined_condition, 'stream closed'));
			onEnd();
		}
		input = (str:String) -> {
			if (!str.startsWith('<stream:stream')) {
				fail(new xmpp.Stanza.Error(cancel, undefined_condition, 'expected stream header'));
				return;
			}
			final header = xmpp.Stream.readHeader(str);
			id = header.id;
			if (id == null || id.length == 0) {
				fail(new xmpp.Stanza.Error(cancel, "invalid-id", 'missing stream id'));
				return;
			}
			input = (str:String) -> {
				final xml = try XML.fromString(str) catch (e) null;
				switch xml?.name {
					case 'handshake':
						onEnd = _onEnd;
						ready = true;
						input = handleString;
						finish();
					case 'stream:error':
						// the server closes the stream after the error
						onEnd = _onEnd;
						finish(parseStreamError(xml));
					case name:
						fail(new xmpp.Stanza.Error(cancel, undefined_condition, 'unexpected element: $name'));
				}
			}
			send(XML.create('handshake', Sha1.encode(id + secret)));
		}
		output(xmpp.Stream.createHeader(xmlns, host, null, lang));
		return this;
	}

	/**
		Sends `xml`, stanzas without `from` are sent from the component host.
	**/
	override public function send(xml:XML):XML {
		if (ready && !xml.has('from') && (xml.name == 'message' || xml.name == 'presence' || xml.name == 'iq'))
			xml.set('from', host);
		return super.send(xml);
	}

	override function prepareResponse(request:IQ, response:IQ) {
		// respond from the address the request was sent to (e.g. a user at the component)
		if (response.from == null)
			response.from = request.to ?? host;
	}

	/**
		Parses a `<stream:error/>`: the condition is the first element in the streams namespace.
	**/
	static function parseStreamError(xml:XML):xmpp.Stanza.Error {
		var text:String = null;
		var condition:Null<xmpp.Stanza.ErrorCondition> = null;
		for (e in xml.elements) {
			if (e.get('xmlns') != 'urn:ietf:params:xml:ns:xmpp-streams')
				continue;
			if (e.name == 'text')
				text = e.text;
			else if (condition == null)
				condition = e.name;
		}
		return new xmpp.Stanza.Error(cancel, condition ?? undefined_condition, text);
	}
}
