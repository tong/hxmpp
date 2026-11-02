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

@:allow(xmpp)
abstract class Stream {
	public static inline var XMLNS = 'http://etherx.jabber.org/streams';

	/** Namespace of the `<open/>` and `<close/>` elements of framed streams (RFC 7395) **/
	public static inline var XMLNS_FRAMING = 'urn:ietf:params:xml:ns:xmpp-framing';

	/** Namespace of stream error conditions **/
	public static inline var XMLNS_STREAMS = 'urn:ietf:params:xml:ns:xmpp-streams';

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
		Handle non-stanza xml (stream errors are reported to `onError` instead).
		This is the last resort of handling received xml; must return `true` in order for the stream to resume.
	**/
	public dynamic function onNonza(xml:XML)
		return false;

	/**
		Called with a stream error received from the peer, or sent by this stream (e.g. `not-well-formed`, `policy-violation`).

		The stream is closed when called (`open` is `false`); `onEnd` follows once the peer closed the stream as well.
		The condition is one of [RFC 6120 4.9.3](https://xmpp.org/rfcs/rfc6120.html#streams-error-conditions),
		an application-specific condition is available as `error.app`.
	**/
	public dynamic function onError(error:xmpp.Stanza.Error) {}

	/** Called once the peer closed the stream; the stream is closed then (`open` and `ready` are `false`) **/
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

	/** Whether the stream is open: the header was sent and the stream was not closed yet, by `end` or by the peer **/
	public var open(default, null) = false;

	/** Whether the stream is ready for stanzas: the peer's stream features were received **/
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

	/** Counts and acknowledges stanzas, if attached (see `StreamManagement`) **/
	var streamManagement:Null<StreamManagement>;

	/** Received data not yet processed **/
	var buf = '';

	/** Position in `buf` and element depth where the scan for the next unit resumes (`nextUnit`) **/
	var scanPos = 0;
	var scanDepth = 0;

	/** Received bytes of an incomplete UTF-8 sequence (`recvBytes`) **/
	var pendingBytes:Null<haxe.io.Bytes>;

	function new(xmlns:String, domain:String, ?lang:String) {
		this.xmlns = xmlns;
		this.domain = domain;
		this.lang = lang;
	}

	/**
		Info `get` query
	**/
	public function get<T:IQ.Payload>(payload:IQ.Payload, ?jid:String, ?handler:(response:Response<T>) -> Void):IQ {
		final iq = new IQ(payload, IQType.Get, makeRandomId(), jid);
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
	public function set<T:IQ.Payload>(payload:IQ.Payload, ?jid:String, ?handler:(response:Response<T>) -> Void):IQ {
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
		Send xml, e.g. a stanza.
	**/
	public function send(xml:XML):XML {
		if (framing && !xml.has('xmlns') && (xml.name == 'message' || xml.name == 'presence' || xml.name == 'iq'))
			// framed elements must be parsable standalone, including their namespace
			xml.set('xmlns', xmlns);
		output(xml);
		if (streamManagement != null && isStanza(xml))
			streamManagement.handleSent(xml);
		return xml;
	}

	static inline function isStanza(xml:XML):Bool
		return xml.name == 'message' || xml.name == 'presence' || xml.name == 'iq';

	/**
		Called before sending the `response` to an iq `request`.
	**/
	function prepareResponse(request:IQ, response:IQ) {}

	/**
		Process incoming raw data (UTF-8), e.g. as read from a socket.

		Like `recv`, but the data may also be split within a multi-byte UTF-8 sequence:
		an incomplete sequence at the end is held back until the rest is received.

		Returns `true` if at least one complete unit was processed.
	**/
	public function recvBytes(bytes:haxe.io.Bytes, pos = 0, ?len:Int):Bool {
		if (len == null)
			len = bytes.length - pos;
		if (pendingBytes != null) {
			final b = new haxe.io.BytesBuffer();
			b.add(pendingBytes);
			b.addBytes(bytes, pos, len);
			bytes = b.getBytes();
			pos = 0;
			len = bytes.length;
		}
		final end = utf8CompleteEnd(bytes, pos, pos + len);
		pendingBytes = (end < pos + len) ? bytes.sub(end, pos + len - end) : null;
		return recv(bytes.getString(pos, end - pos, UTF8));
	}

	/**
		Returns the end of `bytes[pos...end]` without an incomplete UTF-8 sequence at its end.
	**/
	static function utf8CompleteEnd(bytes:haxe.io.Bytes, pos:Int, end:Int):Int {
		// a sequence is at most 4 bytes: look back for its lead byte
		var i = end - 1;
		final min = (end - 4 > pos) ? end - 4 : pos;
		while (i >= min) {
			final c = bytes.get(i);
			if (c & 0xC0 != 0x80) {
				final size = if (c & 0x80 == 0) 1 else if (c & 0xE0 == 0xC0) 2 else if (c & 0xF0 == 0xE0) 3 else if (c & 0xF8 == 0xF0) 4 else 1;
				return (i + size > end) ? i : end;
			}
			i--;
		}
		return end;
	}

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
					if (open)
						input(e.toString());
					continue;
				}
			}
			// A closed stream only waits for the peer's closing tag
			if (open)
				input(unit);
		}
		if (open && maxBufferSize > 0 && buf.length > maxBufferSize)
			sendStreamError(policy_violation);
		return processed;
	}

	static inline var STREAM_END = '</stream:stream>';

	/**
		Removes and returns the next complete unit from `buf`, `STREAM_END` if the stream was closed,
		or `null` if more data is needed: the scan then resumes where it stopped (`scanPos`, `scanDepth`)
		once more data was received, instead of rescanning the incomplete unit.

		An incomplete unit always starts at position `0`: data before it (whitespace, declarations) is discarded.
	**/
	function nextUnit():Null<String> {
		var i = scanPos;
		var depth = scanDepth;
		while (true) {
			final lt = buf.indexOf('<', i);
			if (depth == 0) {
				// Discard whitespace (keepalives) between top-level elements
				buf = (lt == -1) ? '' : buf.substr(lt);
				i = 0;
				if (lt == -1)
					return more(0, 0);
			} else if (lt == -1)
				return more(buf.length, depth);
			final pos = (depth == 0) ? 0 : lt;
			if (startsAt(pos, '<?') || startsAt(pos, '<!--') || startsAt(pos, '<![CDATA[')) {
				// Skip xml declaration, comments and character data
				final close = startsAt(pos, '<?') ? '?>' : startsAt(pos, '<!--') ? '-->' : ']]>';
				final end = buf.indexOf(close, pos);
				if (end == -1)
					return more(pos, depth);
				if (depth == 0) {
					buf = buf.substr(end + close.length);
					i = 0;
				} else
					i = end + close.length;
				continue;
			}
			final gt = tagEnd(pos);
			if (gt == -1)
				return more(pos, depth);
			if (buf.charCodeAt(pos + 1) == '/'.code) {
				if (depth == 0) {
					// Closing tag at top-level closes the stream
					buf = buf.substr(gt + 1);
					scanPos = scanDepth = 0;
					return STREAM_END;
				}
				if (--depth == 0)
					return takeUnit(gt + 1);
			} else {
				final selfClosing = buf.charCodeAt(gt - 1) == '/'.code;
				if (depth == 0 && (selfClosing || startsAt(pos, '<stream:stream')))
					return takeUnit(gt + 1);
				if (!selfClosing)
					depth++;
			}
			i = gt + 1;
		}
	}

	/** More data is needed: remembers where to resume the scan **/
	inline function more(pos:Int, depth:Int):Null<String> {
		scanPos = pos;
		scanDepth = depth;
		return null;
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

	/** Removes and returns the unit `buf[0...end]` **/
	function takeUnit(end:Int):String {
		final unit = buf.substr(0, end);
		buf = buf.substr(end);
		scanPos = scanDepth = 0;
		return unit;
	}

	/**
		Closes the stream: sends the closing tag (nothing if the stream is not open).

		`onEnd` is called once the peer closed the stream as well.
	**/
	public function end() {
		if (!open)
			return;
		if (streamManagement != null)
			streamManagement.handleEnd();
		output(framing ? '<close xmlns="$XMLNS_FRAMING"/>' : '</stream:stream>');
		// received data is kept: the peer's closing tag may already be buffered
		reset(false);
	}

	/**
		Sends a stream error with `condition` (and an application-specific `app` element), closes the stream
		and reports the error to `onError`.
	**/
	function sendStreamError(condition:xmpp.Stanza.ErrorCondition, ?app:XML) {
		if (!open)
			return;
		final xml = XML.create('stream:error').set('xmlns:stream', XMLNS).append(XML.create(condition).set('xmlns', XMLNS_STREAMS));
		if (app != null)
			xml.append(app);
		output(xml);
		end();
		final error = new xmpp.Stanza.Error(cancel, condition);
		if (app != null)
			error.app = {condition: app.name, xmlns: app.ns, properties: [for (e in app.elements) e], element: app};
		onError(error);
	}

	/**
		Handles a `<stream:error/>` received from the peer: closes the stream and reports the error to `onError`.
	**/
	function handleStreamError(xml:XML) {
		final error = parseStreamError(xml);
		end();
		onError(error);
	}

	/**
		Parses a `<stream:error/>`: the condition is the first element in the streams namespace
		(`undefined-condition` if there is none), with its `<text/>` and an application-specific condition.
	**/
	public static function parseStreamError(xml:XML):xmpp.Stanza.Error {
		var condition:Null<xmpp.Stanza.ErrorCondition> = null;
		var text:Null<String> = null;
		var app:Null<xmpp.Stanza.ApplicationErrorCondition> = null;
		for (e in xml.elements) {
			if (e.is(XMLNS_STREAMS)) {
				if (e.name == 'text')
					text = e.text;
				else if (condition == null)
					condition = e.name;
			} else if (app == null && e.ns != null)
				app = {condition: e.name, xmlns: e.ns, properties: [for (c in e.elements) c], element: e};
		}
		return new xmpp.Stanza.Error(cancel, condition ?? undefined_condition, text, app);
	}

	function handleString(str:String) {
		if (!ready)
			return;
		final xml = try XML.fromString(str) catch (e) {
			#if debug
			trace(e);
			#end
			sendStreamError('not-well-formed');
			return;
		}
		if (xml != null)
			handleXML(xml);
	}

	function handleXML(xml:XML) {
		final stanza = isStanza(xml);
		if (streamManagement != null) {
			if (stanza)
				streamManagement.handleReceived();
			else if (xml.is(StreamManagement.XMLNS)) {
				streamManagement.handleNonza(xml);
				return;
			}
		}
		if (stanza && xml.has('xmlns') && xml.get('xmlns') != xmlns) {
			#if debug
			trace('ignoring stanza with invalid namespace: ${xml.get('xmlns')}');
			#end
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
						if (iq.id != null) send(iq.createError({type: modify, condition: bad_request}));
				}
			case 'stream:error':
				handleStreamError(xml);
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

	/**
		Closes the stream state; the received data is discarded if `clearBuffer`.
	**/
	function reset(clearBuffer = true) {
		open = false;
		ready = false;
		jid = null;
		serverFeatures = null;
		if (streamManagement != null)
			streamManagement.handleReset(cast queries);
		queries = new Map();
		if (clearBuffer) {
			buf = '';
			scanPos = scanDepth = 0;
			pendingBytes = null;
		}
	}

	/**
		Sends the stream header, opening the stream.
	**/
	function sendHeader(header:String) {
		open = true;
		output(header);
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

	/**
		Reads the attributes of a stream header (or `<open/>`), `null` if it is not well-formed.
	**/
	static function readHeader(str:String):Null<Header> {
		final r = ~/^(<\?xml) (.)+\?>/;
		if (r.match(str))
			str = r.matchedRight();
		if (!str.endsWith('/>')) {
			final i = str.indexOf(">");
			if (i == -1)
				return null;
			str = str.substr(0, i) + '/>';
		}
		final xml = try XML.fromString(str) catch (e) null;
		if (xml == null)
			return null;
		return {
			id: xml.get("id"),
			from: xml.get("from"),
			to: xml.get("to"),
			version: xml.get("version"),
			lang: xml.get("xml:lang")
		};
	}

	/**
		Returns the `<stream:features/>` of `str`, `null` if there are none (yet); throws if they are not well-formed.
	**/
	static function readFeatures(str:String):Null<XML> {
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
