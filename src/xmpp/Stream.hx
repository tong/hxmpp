package xmpp;

import xmpp.IQ;
import xmpp.Presence;
import xmpp.Response;

using StringTools;

private typedef Header = {
	from:String,
	to:String,
	id:String,
	lang:String,
	version:String
}

private typedef Query = {
	/** Name of the request stanza (`iq` or `presence`) **/
	name:String,

	/** Address the request was sent to **/
	to:Null<String>,

	handler:XML->Void
}

private typedef Feature = {
	xmlns:String,
	handler:IQ->IQ
}

abstract class Stream {
	public static inline var XMLNS = 'http://etherx.jabber.org/streams';

	/** Namespace of the `<open/>` and `<close/>` elements of framed streams (RFC 7395) **/
	public static inline var XMLNS_FRAMING = 'urn:ietf:params:xml:ns:xmpp-framing';

	/** Handle message stanzas **/
	public dynamic function onMessage(m:Message) {}

	/** Handle presence stanzas **/
	public dynamic function onPresence(p:Presence) {}

	/**
		Handle iq requests (get, set) not handled by a `features` handler.

		`res` MUST be called with the response, or `null` if the request is not supported
		(answered with `service-unavailable`). By default all requests are answered with `service-unavailable`.
	**/
	public dynamic function onIQ(iq:IQ, res:Null<Response<XML>>->Void) {
		res(null);
	}

	/**
		Handle non-stanza xml.  
		This is the last ressort of handling received xml; must return `true` in order for the stream to resume.
	**/
	public dynamic function onNonza(xml:XML)
		return false;

	/** Stream end handler **/
	public dynamic function onEnd() {}

	/**
		Called before `onEnd` if the server closed a framed stream with a `see-other-uri`,
		the endpoint to reconnect to (e.g. for load balancing).

		Do not accept endpoints with a lower security context (e.g. `ws://` after `wss://`).
	**/
	public dynamic function onRedirect(uri:String) {}

	public final xmlns:String;
	public final domain:String;
	public final lang:String;

	public var id(default, null):String;
	public var version(default, null) = "1.0";
	public var ready(default, null) = false;

	/**
		The address of this stream's entity, once known (client: after resource binding).
	**/
	@:allow(xmpp.client.Authentication)
	public var jid(default, null):Null<String>;

	/**
		The `<stream:features/>` last received from the server (e.g. after authentication), `null` before.
	**/
	public var serverFeatures(default, null):Null<XML>;

	// public var ready = false;
	public var features = new Map<String, IQ->(Null<Response<XML>>->Void)->Void>();

	/**
		Maximum size (in characters) of received data buffered until a unit is complete, `0` for no limit.

		If exceeded, the stream is closed with a `policy-violation` stream error.
	**/
	public var maxBufferSize = 1024 * 1024;

	/**
		Use the framing of the WebSocket binding ([RFC 7395](https://www.rfc-editor.org/rfc/rfc7395)):
		the stream is opened with `<open/>` and closed with `<close/>`, and every sent element carries its namespace.

		Set before starting the stream; each WebSocket message must be passed to `recv`, and each `output` sent as one message.
	**/
	public var framing = false;

	public var input:String->Void;
	public var output:String->Void;

	var queries = new Map<String, Query>();
	/** Received data not yet processed **/
	var buf = '';

	function new(xmlns:String, domain:String, ?lang:String) {
		this.xmlns = xmlns;
		this.domain = domain;
		this.lang = lang;
	}

	/**
		Info `get` query
	**/
	public function get<T:IQ.Payload, R>(payload:IQ.Payload, ?jid:String, ?handler:(response:Response<T>) -> Void):IQ {
		final iq = new IQ(payload, IQType.Get, makeRandomId(), jid);
		if (iq.id == null)
			iq.id = makeRandomId();
		if (handler != null) {
			addQuery(iq, xml -> {
				final iq:IQ = xml;
				switch iq.type {
					case Result: handler(Result(cast iq.payload));
					case Error: handler(Error(responseError(iq)));
					default:
				}
			});
		}
		send(iq);
		return iq;
	}

	/**
		Info `set` query
	**/
	public function set<T:IQ.Payload>(payload:IQ.Payload, ?jid:String, handler:(response:Response<T>) -> Void):IQ {
		final iq = new IQ(payload, IQType.Set, makeRandomId(), jid);
		if (handler != null) {
			addQuery(iq, xml -> {
				final iq:IQ = xml;
				switch iq.type {
					case Result: handler(Result(cast iq.payload));
					case Error: handler(Error(responseError(iq)));
					default:
				}
			});
		}
		send(iq);
		return iq;
	}

	public function query(stanza:Stanza, handler:(response:XML) -> Void) {
		if (stanza.id == null)
			stanza.id = makeRandomId();
		final xml = stanza.toXML();
		if (handler != null)
			queries.set(stanza.id, {name: xml.name, to: stanza.to, handler: handler});
		send(xml);
	}

	/**
		Returns the error of an error response, with its included payload.
	**/
	static function responseError(iq:IQ):xmpp.Stanza.Error {
		final e = iq.error ?? new xmpp.Stanza.Error(cancel, undefined_condition);
		e.payload = iq.payload;
		return e;
	}

	function addQuery(iq:IQ, handler:XML->Void) {
		queries.set(iq.id, {name: IQ.NAME, to: iq.to, handler: handler});
	}

	/**
		Send stanza
	**/
	// public function send(xml:XML) : XML {
	// 	output(xml);
	//        return xml;
	// }
	// public function send(stanza:Stanza) : Stanza {
	// 	output(stanza.toString());
	//        return stanza;
	// }

	public function send(xml:XML):XML {
		if (framing && !xml.has('xmlns') && (xml.name == 'message' || xml.name == 'presence' || xml.name == 'iq'))
			// framed elements must be parsable standalone, including their namespace
			xml.set('xmlns', xmlns);
		output(xml);
		return xml;
	}

	/**
		Called before sending the `response` to an iq `request`.
	**/
	function prepareResponse(request:IQ, response:IQ) {}

	/*
		public function sendStanza<T:xmpp.Stanza>(stanza:T, ?handler:T->Void) : T {
			if(handler != null) {
				if(stanza.id == null) stanza.id = Stream.makeRandomId();
				//queries.set(stanza.id, handler);
			}
			// if(stanza.id != null) {
			//     queries.set(stanza.id, handler);
			// }
			return stanza;
		}
	 */
	/**
		Process incoming data.

		The data may be split at any position; complete units (the stream header or a top-level element)
		are passed to `input` one by one, incomplete data is buffered until more is received.

		Returns `true` if at least one complete unit was processed.
	**/
	public function recv(str:String):Bool {
		if (str == null || str.length == 0)
			return false;
		buf += str;
		var processed = false;
		// `buf` is re-read on each iteration since a handler may reset the stream
		while (buf.length > 0) {
			final unit = nextUnit();
			if (unit == null)
				break;
			processed = true;
			if (unit == STREAM_END) {
				reset();
				onEnd();
				break;
			}
			if (framing && (unit.startsWith('<close') || unit.startsWith('<error'))) {
				final xml = try XML.fromString(unit) catch (e) null;
				if (xml != null && xml.name == 'close' && xml.get('xmlns') == XMLNS_FRAMING) {
					final uri = xml.get('see-other-uri');
					reset();
					if (uri != null)
						onRedirect(uri);
					onEnd();
					break;
				}
				if (xml != null && xml.name == 'error' && xml.get('xmlns') == XMLNS) {
					// unprefixed stream error, handled as <stream:error/>
					final e = XML.create('stream:error').set('xmlns:stream', XMLNS);
					for (c in xml.elements)
						e.append(c);
					input(e.toString());
					continue;
				}
			}
			input(unit);
		}
		if (maxBufferSize > 0 && buf.length > maxBufferSize) {
			output('<stream:error xmlns:stream="http://etherx.jabber.org/streams"><policy-violation xmlns="urn:ietf:params:xml:ns:xmpp-streams"/></stream:error>');
			end();
		}
		return processed;
	}

	static inline var STREAM_END = '</stream:stream>';

	/**
		Removes and returns the next complete unit from `buf`, `STREAM_END` if the stream was closed,
		or `null` if more data is needed.
	**/
	function nextUnit():Null<String> {
		var depth = 0;
		var start = -1;
		var i = 0;
		while (true) {
			final lt = buf.indexOf('<', i);
			if (start == -1) {
				// Discard whitespace (keepalives) between top-level elements
				buf = (lt == -1) ? '' : buf.substr(lt);
				if (lt == -1)
					return null;
				i = 0;
			} else if (lt == -1)
				return null;
			final pos = (start == -1) ? 0 : lt;
			if (startsAt(pos, '<?') || startsAt(pos, '<!--') || startsAt(pos, '<![CDATA[')) {
				// Skip xml declaration, comments and character data
				final close = startsAt(pos, '<?') ? '?>' : startsAt(pos, '<!--') ? '-->' : ']]>';
				final end = buf.indexOf(close, pos);
				if (end == -1)
					return null;
				if (start == -1) {
					buf = buf.substr(end + close.length);
					i = 0;
				} else
					i = end + close.length;
				continue;
			}
			final gt = tagEnd(pos);
			if (gt == -1)
				return null;
			if (buf.charCodeAt(pos + 1) == '/'.code) {
				if (depth == 0) {
					// Closing tag at top-level closes the stream
					buf = buf.substr(gt + 1);
					return STREAM_END;
				}
				if (--depth == 0)
					return takeUnit(start, gt + 1);
			} else {
				final selfClosing = buf.charCodeAt(gt - 1) == '/'.code;
				if (depth == 0) {
					start = pos;
					if (selfClosing || startsAt(pos, '<stream:stream'))
						return takeUnit(start, gt + 1);
				}
				if (!selfClosing)
					depth++;
			}
			i = gt + 1;
		}
	}

	/**
		Returns the position of the `>` ending the tag starting at `pos`, ignoring `>` in quoted attribute values.
	**/
	function tagEnd(pos:Int):Int {
		var quote = 0;
		for (i in pos...buf.length) {
			final c = StringTools.fastCodeAt(buf, i);
			if (quote != 0) {
				if (c == quote)
					quote = 0;
			} else if (c == '"'.code || c == "'".code) {
				quote = c;
			} else if (c == '>'.code) {
				return i;
			}
		}
		return -1;
	}

	inline function startsAt(pos:Int, str:String):Bool
		return buf.substr(pos, str.length) == str;

	function takeUnit(start:Int, end:Int):String {
		final unit = buf.substring(start, end);
		buf = buf.substr(end);
		return unit;
	}

	/**
		End stream
	**/
	public function end() {
		output(framing ? '<close xmlns="$XMLNS_FRAMING"/>' : '</stream:stream>');
		reset();
	}

	function handleString(str:String) {
		if (!ready)
			return;
		final xml = try XML.fromString(str) catch (e) {
			#if debug
			trace(e);
			#end
			output('<stream:error xmlns:stream="http://etherx.jabber.org/streams"><not-well-formed xmlns="urn:ietf:params:xml:ns:xmpp-streams"/></stream:error>');
			end();
			return;
		}
		if (xml != null)
			handleXML(xml);
	}

	function handleXML(xml:XML) {
		final isStanza = xml.name == 'message' || xml.name == 'presence' || xml.name == 'iq';
		if (isStanza && xml.has('xmlns') && xml.get('xmlns') != xmlns) {
			trace("invalid stream namespace");
			return;
		}
		if (xml.has("id")) {
			final id = xml.get("id");
			final query = queries.get(id);
			if (query != null) {
				if (isResponse(query, xml)) {
					queries.remove(id);
					query.handler(xml);
					return;
				}
				#if debug
				trace('ignoring response to $id from unexpected sender: ${xml.get("from")}');
				#end
			}
		}
		switch xml.name {
			case 'message':
				onMessage(xml);
			case 'presence':
				final type = xml.get('type');
				if (type != null && PresenceType.fromString(type) == null) {
					// An invalid type must not be taken as available presence
					#if debug
					trace('ignoring presence with invalid type: $type');
					#end
					return;
				}
				onPresence(xml);
			case 'iq':
				final iq:IQ = xml;
				switch iq.type {
					case Result, Error:
						#if debug
						trace('unhandled iq response');
						#end
					case Get, Set:
						if (iq.id == null) {
							// No response possible without id
							#if debug
							trace('dropping iq request without id');
							#end
							return;
						}
						if (iq.payload == null) {
							send(iq.createError({type: modify, condition: bad_request}));
							return;
						}
						final ns = iq.payload.xmlns;
						function handleRes(?res) {
							final response = (res == null) ? iq.createError({type: cancel, condition: service_unavailable}) : switch res {
								case Result(r): iq.createResult(r);
								case Error(e): iq.createError(e);
							}
							prepareResponse(iq, response);
							send(response);
						}
						if (features != null && features.exists(ns)) {
							features.get(ns)(iq, handleRes);
						} else {
							onIQ(iq, handleRes);
						}
					case _:
						// Missing or invalid type
						if (iq.id != null)
							send(iq.createError({type: modify, condition: bad_request}));
				}
			default:
				if (!onNonza(xml))
					end();
		}
	}

	/**
		Returns `true` if `xml` is a valid response to the pending `query`:
		same stanza kind, a `result`/`error` iq, and sent by the entity the request was addressed to
		([RFC 6120 8.1.2.1](https://xmpp.org/rfcs/rfc6120.html#stanzas-attributes-to-c2s)).
	**/
	function isResponse(query:Query, xml:XML):Bool {
		if (xml.name != query.name)
			return false;
		if (query.name == IQ.NAME) {
			final type = xml.get('type');
			if (type != IQType.Result && type != IQType.Error)
				return false;
		}
		final from = xml.get('from');
		if (query.to == null || (jid != null && sameJid(query.to, jid, true))) {
			// Request to the own account, handled by the server on behalf of it
			if (from == null)
				return true;
			if (jid == null)
				return sameJid(from, domain);
			return sameJid(from, jid) || sameJid(from, jid, true);
		}
		return sameJid(from, query.to, query.name == Presence.NAME);
	}

	static function sameJid(a:Null<String>, b:Null<String>, bare = false):Bool {
		return (a == null || b == null) ? a == b : normalizeJid(a, bare) == normalizeJid(b, bare);
	}

	static function normalizeJid(str:String, bare:Bool):String
		return Jid.normalize(bare ? Jid.parseBare(str) : str);


	function reset() {
		ready = false;
		jid = null;
		serverFeatures = null;
		queries = new Map();
		buf = '';
	}

	/**
		Returns a random hex string of given `length`, to be used as stanza or session id.
	**/
	public static function makeRandomId(length = 16):String
		return Random.bytes((length + 1) >> 1).toHex().substr(0, length);


	/**
		Returns the opening stream header, the `<open/>` element for framed streams.
	**/
	function createStreamHeader(to:String, ?version:String):String {
		if (!framing)
			return createHeader(xmlns, to, version, lang);
		final xml = XML.create('open').set('xmlns', XMLNS_FRAMING).set('to', to);
		if (version != null)
			xml.set('version', version);
		if (lang != null)
			xml.set('xml:lang', lang);
		return xml.toString();
	}

	static function createHeader(xmlns:String, to:String, ?version:String, ?lang:String):String {
		final xml = XML.create('stream:stream')
			.set('xmlns', xmlns)
			.set('xmlns:stream', xmpp.Stream.XMLNS)
			.set('to', to);
		if (version != null)
			xml.set('version', version);
		if (lang != null)
			xml.set('xml:lang', lang);
		var str = xml.toString();
		str = str.substr(0, str.lastIndexOf('/')) + '>';
		return str;
	}

	static function readHeader(str:String):Header {
		final r = ~/^(<\?xml) (.)+\?>/;
		if (r.match(str))
			str = r.matchedRight();
		// TODO handle stream:error
		// var i = str.lastIndexOf( "/>" );
		if (!str.endsWith('/>')) {
			final i = str.indexOf(">");
			if (i == -1)
				throw 'invalid stream header'; // TODO:
			str = str.substr(0, i) + '/>';
		}
		final xml = XML.fromString(str);
		return {
			id: xml.get("id"),
			from: xml.get("from"),
			to: xml.get("to"),
			version: xml.get("version"),
			lang: xml.get("xml:lang")
		};
	}

	static function readFeatures(str:String):XML {
		var i = str.indexOf("<stream:features");
		if (i == -1)
			return null;
		str = str.substr(i);
		i = str.indexOf("</stream:stream>");
		if (i != -1)
			str = str.substr(0, i);
		// complete element, with content or self-closing (no features)
		if (str.indexOf("</stream:features") == -1 && !str.trim().endsWith("/>"))
			return null;
		return XML.fromString(str);
	}
}
