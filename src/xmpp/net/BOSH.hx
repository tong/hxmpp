package xmpp.net;

import haxe.crypto.Sha1;

using StringTools;

/**
	A request sent to the connection manager, kept until its response was processed.
**/
private typedef Request = {
	final rid:Int;
	final body:String;

	/** Set if this is the session termination request **/
	final terminate:Bool;

	/** Number of times the request was repeated **/
	var retries:Int;

	/** Number of HTTP requests made for it without a result yet **/
	var outstanding:Int;

	/** The response, once received, until processed in request order **/
	var response:Null<XML>;
}

/**
	XMPP over BOSH (Bidirectional-streams Over Synchronous HTTP): the stream is transported in HTTP request/response pairs,
	e.g. for clients that can not keep a TCP or WebSocket connection open.

	The session (request ids, holding and polling, acknowledgements, recovery of lost requests) is managed here,
	the HTTP requests are made by `request`: on js (browser and nodejs) `haxe.Http` is used by default,
	on other targets set it to an asynchronous HTTP POST implementation.
	The stream is used as usual, its `output` is taken over:

		final bosh = new BOSH('https://example.com/http-bind');
		final stream = new xmpp.client.Stream('example.com');
		bosh.attach(stream);
		stream.start(features -> {
			// authenticate (no STARTTLS, TLS is provided by https://)
			stream.authenticate(node, resource, password, mechanism, (?e) -> {});
		});
		stream.send(message);
		stream.end(); // terminates the session

	Rules:
	- Starting the stream creates the session, a restart (e.g. after authentication) restarts the stream within the session.
	- Ending the stream (`Stream.end`) terminates the session, `Stream.onEnd` is called once the connection manager confirmed.
	- If the connection manager terminates the session, `onError` is called with the condition, then `Stream.onEnd`
	  (`Stream.onRedirect` for a `see-other-uri` condition).
	- Do not set `Stream.framing`, and do not send whitespace keepalives: the pending request keeps the session alive.
	- `request` must not time out before `wait` seconds plus a margin: the connection manager holds a request that long.
	  A failed request is repeated (`retries`); if the connection stays broken the session is terminated.
	- With `hold = 0` (a polling session) call `poll` at an interval of at least `polling` seconds.
	- Use a `https://` url; the key sequence (`keyLength`) only protects an unencrypted session against request injection.

	The BOSH endpoint of a domain can be discovered with
	[XEP-0156](https://xmpp.org/extensions/xep-0156.html) (`urn:xmpp:alt-connections:xbosh`).

	- [XEP-0124: Bidirectional-streams Over Synchronous HTTP (BOSH)](https://xmpp.org/extensions/xep-0124.html)
	- [XEP-0206: XMPP Over BOSH](https://xmpp.org/extensions/xep-0206.html)
**/
@xep(124)
class BOSH {
	/** Namespace of the `<body/>` wrapper element **/
	public static inline var XMLNS = 'http://jabber.org/protocol/httpbind';

	/** Namespace of the XMPP specific attributes (`xmpp:version`, `xmpp:restart`) **/
	public static inline var XMLNS_XBOSH = 'urn:xmpp:xbosh';

	/** Highest supported BOSH protocol version **/
	public static inline var VERSION = '1.6';

	/** Content type of requests and responses **/
	public static inline var CONTENT_TYPE = 'text/xml; charset=utf-8';

	/** Link relation of the BOSH endpoint in host-meta ([XEP-0156](https://xmpp.org/extensions/xep-0156.html)) **/
	public static inline var REL = 'urn:xmpp:alt-connections:xbosh';

	/** Terminal binding condition of a session the connection manager closed because of an XMPP stream error **/
	public static inline var REMOTE_STREAM_ERROR = 'remote-stream-error';

	/** Minimum length of a key sequence: the last key is sent together with the first key of the next sequence **/
	static inline var MIN_KEY_LENGTH = 2;

	/**
		Makes the HTTP POST request with `body` to `url`.

		`onResponse` is called with the body of a successful response (HTTP 200), `onError` with a description if the request failed.
		Each call is one request; requests may be made concurrently (see `requests`).
		Set the `Content-Type` header to `CONTENT_TYPE`, and a timeout longer than `wait` seconds.
	**/
	public dynamic function request(body:String, onResponse:(body:String) -> Void, onError:(error:String) -> Void) {
		#if js
		final http = new haxe.Http(url);
		http.addHeader('Content-Type', CONTENT_TYPE);
		http.setPostData(body);
		http.onData = onResponse;
		http.onError = onError;
		http.request(true);
		#else
		onError('BOSH.request is not implemented on this target');
		#end
	}

	/**
		Called if the session was terminated with an error, before `Stream.onEnd`:
		a terminal binding condition of the connection manager (e.g. `remote-connection-failed`, `policy-violation`, `item-not-found`,
		`remote-stream-error` after the `<stream:error/>` was passed to the stream), `error` if a recoverable binding error could not be
		recovered from, or the error of a failed request.
	**/
	public dynamic function onError(error:String) {}

	/** HTTP(S) url of the connection manager **/
	public final url:String;

	/**
		Maximum number of requests the connection manager may hold (keep waiting for payloads) at a time, `0` for a polling session.
		Set to the value accepted by the connection manager on session creation.
	**/
	public var hold:Int;

	/**
		Longest time in seconds the connection manager may wait before responding to a request.
		Set to the value accepted by the connection manager on session creation.
	**/
	public var wait:Int;

	/** Server to connect to (`proto:host:port`, e.g. `xmpp:example.com:5222`), for a connection manager serving several domains **/
	public var route:Null<String>;

	/** Address of the connecting entity, forwarded to the server (e.g. for SASL EXTERNAL with HTTP level authentication) **/
	public var from:Null<String>;

	/** Number of times a failed request is repeated (with the same `rid`) before the session is terminated **/
	public var retries = 2;

	/**
		Length of the key sequences protecting an unencrypted session against injected requests
		([XEP-0124 15](https://xmpp.org/extensions/xep-0124.html#keys)), `0` for none. Not needed with a `https://` url.
	**/
	public var keyLength = 0;

	/** The stream transported by this session **/
	public var stream(default, null):Null<xmpp.Stream>;

	/** Session id, `null` if no session is established **/
	public var sid(default, null):Null<String>;

	/** Request id of the last request made **/
	public var rid(default, null) = 0;

	/** Maximum number of simultaneous requests permitted by the connection manager, `null` if not limited **/
	public var requests(default, null):Null<Int>;

	/** Shortest allowed interval in seconds between empty requests of a polling session, `null` if not limited **/
	public var polling(default, null):Null<Int>;

	/** Longest allowed period in seconds without a pending request, `null` if not limited **/
	public var inactivity(default, null):Null<Int>;

	/** Longest session pause in seconds the connection manager permits, `null` if pausing is not supported **/
	public var maxpause(default, null):Null<Int>;

	/** Whether the session is paused (see `pause`) **/
	public var paused(default, null) = false;

	/** Number of requests without a processed response **/
	public var pending(get, never):Int;

	inline function get_pending()
		return inflight.length;

	/** Payloads to send with the next request **/
	var queue:Array<String> = [];

	/** Requests without a processed response, in `rid` order **/
	var inflight:Array<Request> = [];

	/** Remaining keys of the current sequence, the next key to send last **/
	var keys:Null<Array<String>>;

	var creating = false;
	var terminating = false;

	/**
		`hold` requests are kept waiting at the connection manager for at most `wait` seconds (see `pending`).
	**/
	public function new(url:String, hold = 1, wait = 60) {
		this.url = url;
		this.hold = hold;
		this.wait = wait;
	}

	/**
		Transports `stream` by this session: its `output` is set.

		Start the stream to create the session.
	**/
	public function attach(stream:xmpp.Stream) {
		this.stream = stream;
		stream.output = handleOutput;
	}

	/**
		Makes an empty request if no request is pending, or sends queued payloads.

		In a session with `hold > 0` the next request is made as soon as a response is received, for a polling session (`hold = 0`)
		poll regularly, at an interval of at least `polling` seconds and less than `inactivity` seconds.
		Returns `true` if a request was made.
	**/
	public function poll():Bool {
		if (sid == null || paused || terminating)
			return false;
		if (flush())
			return true;
		if (inflight.length > 0)
			return false;
		send(createBody());
		return true;
	}

	/**
		Requests a session pause of `seconds` (at most `maxpause`): the connection manager responds to all pending requests immediately
		and keeps the session for that long without a request, e.g. while a web page is left.
		Nothing is sent until `resume` is called, which must happen within `seconds`.

		Returns `false` if the connection manager does not support pausing (`maxpause`), or that long.
	**/
	public function pause(seconds:Int):Bool {
		if (sid == null || paused || terminating || maxpause == null || seconds > maxpause)
			return false;
		paused = true;
		send(createBody().set('pause', Std.string(seconds)));
		return true;
	}

	/**
		Resumes a paused session: queued payloads are sent, or an empty request is made.
	**/
	public function resume() {
		if (!paused)
			return;
		paused = false;
		poll();
	}

	/**
		Handles the stream output: the stream header creates the session or restarts the stream,
		the stream end terminates the session, everything else is sent as payload.
	**/
	function handleOutput(str:String) {
		if (str.startsWith('<stream:stream') || (str.startsWith('<open') && str.indexOf(xmpp.Stream.XMLNS_FRAMING) != -1)) {
			if (sid == null)
				createSession();
			else
				restart();
		} else if (str.startsWith('</stream:stream') || (str.startsWith('<close') && str.indexOf(xmpp.Stream.XMLNS_FRAMING) != -1)) {
			terminate();
		} else if (str.trim().length > 0) {
			queue.push(str);
			flush();
		}
	}

	function createSession() {
		if (creating)
			return;
		reset();
		creating = true;
		rid = initialRid();
		final body = createBody()
			.set('to', stream.domain)
			.set('ver', VERSION)
			.set('wait', Std.string(wait))
			.set('hold', Std.string(hold))
			.set('ack', '1')
			.set('xmlns:xmpp', XMLNS_XBOSH)
			.set('xmpp:version', stream.version ?? '1.0');
		if (stream.lang != null)
			body.set('xml:lang', stream.lang);
		if (route != null)
			body.set('route', route);
		if (from != null)
			body.set('from', from);
		send(body);
	}

	function restart() {
		final body = createBody().set('xmlns:xmpp', XMLNS_XBOSH).set('xmpp:restart', 'true').set('to', stream.domain);
		if (stream.lang != null)
			body.set('xml:lang', stream.lang);
		send(body);
	}

	function terminate() {
		if (terminating)
			return;
		if (sid == null) {
			// No session to terminate: creation failed, or the stream is ended before its response
			queue = [];
			if (creating)
				terminating = true;
			return;
		}
		terminating = true;
		// The termination request may exceed the request limit; queued payloads (e.g. unavailable presence) are forwarded
		final body = createBody().set('type', 'terminate');
		appendQueue(body);
		send(body, true);
	}

	/**
		Sends the queued payloads if a request can be made, returns `true` if sent.
	**/
	function flush():Bool {
		if (sid == null || paused || terminating || queue.length == 0 || !canRequest())
			return false;
		final body = createBody();
		appendQueue(body);
		send(body);
		return true;
	}

	inline function canRequest():Bool
		return requests == null || inflight.length < requests;

	function appendQueue(body:XML) {
		for (str in queue) {
			final xml = try XML.fromString(str) catch (e) {
				#if debug
				trace('dropping invalid payload: $str');
				#end
				continue;
			}
			// Payloads must be qualified: stanzas carry the stream namespace, nonzas their own
			if (xml.ns == null && (xml.name == 'message' || xml.name == 'presence' || xml.name == 'iq'))
				xml.set('xmlns', stream.xmlns);
			body.append(xml);
		}
		queue = [];
	}

	/**
		Creates the wrapper of the next request: `rid`, `sid`, acknowledgement of the received responses and the key.
	**/
	function createBody():XML {
		final body = XML.create('body').set('xmlns', XMLNS).set('rid', Std.string(++rid));
		if (sid != null) {
			body.set('sid', sid);
			// Acknowledge the highest rid responded to, if not all previous requests were (then it is implied)
			if (inflight.length > 0)
				body.set('ack', Std.string(inflight[0].rid - 1));
		}
		if (keyLength > 0) {
			if (keys == null) {
				keys = generateKeys();
				body.set('newkey', keys.pop());
			} else {
				body.set('key', keys.pop());
				if (keys.length == 0) {
					// The last key of a sequence is sent with the first of the next one
					keys = generateKeys();
					body.set('newkey', keys.pop());
				}
			}
		}
		return body;
	}

	/**
		Returns a key sequence `K(1)..K(n)`: `K(1) = hex(SHA-1(seed))`, `K(i) = hex(SHA-1(K(i-1)))`.
		The keys are used from the last to the first.
	**/
	function generateKeys():Array<String> {
		final n = (keyLength < MIN_KEY_LENGTH) ? MIN_KEY_LENGTH : keyLength;
		final keys = [Sha1.encode(xmpp.Stream.makeRandomId(40))];
		for (i in 1...n)
			keys.push(Sha1.encode(keys[i - 1]));
		return keys;
	}

	/**
		Returns a random initial request id: large and unpredictable, leaving room to increment within the session.
	**/
	static function initialRid():Int {
		final b = xmpp.Random.bytes(4);
		return ((b.get(0) & 0x3f) << 24) | (b.get(1) << 16) | (b.get(2) << 8) | b.get(3) | 1;
	}

	function send(body:XML, terminate = false) {
		final r:Request = {
			rid: Std.parseInt(body.get('rid')),
			body: body.toString(),
			terminate: terminate,
			retries: 0,
			outstanding: 0,
			response: null
		};
		inflight.push(r);
		post(r);
	}

	function post(r:Request) {
		r.outstanding++;
		request(r.body, res -> handleResponse(r, res), e -> handleRequestError(r, e));
	}

	function handleRequestError(r:Request, error:String) {
		r.outstanding--;
		// A repeated request may still succeed; a request of an ended session is not of interest
		if (r.outstanding > 0 || !inflight.contains(r) || r.response != null)
			return;
		if (r.retries < retries) {
			r.retries++;
			post(r);
			return;
		}
		endSession(error);
	}

	function handleResponse(r:Request, str:String) {
		r.outstanding--;
		if (!inflight.contains(r) || r.response != null)
			return;
		final body = try XML.fromString(str) catch (e) null;
		if (body == null || body.name != 'body' || !body.is(XMLNS)) {
			endSession('invalid response');
			return;
		}
		if (body.get('type') == 'error') {
			// Recoverable: repeat the request and the preceding ones without response, unless a repetition is outstanding
			if (r.outstanding == 0)
				recover(r);
			return;
		}
		r.response = body;
		if (body.has('report')) {
			// The response to that request was lost: repeat it, unless a repetition is outstanding
			final report = Std.parseInt(body.get('report'));
			for (q in inflight)
				if (q.rid == report && q.response == null && (q.outstanding == 0 || q.retries == 0)) {
					q.retries++;
					post(q);
				}
		}
		// Responses are processed in the order the requests were made
		while (inflight.length > 0 && inflight[0].response != null) {
			final r = inflight.shift();
			process(r, r.response);
		}
	}

	function recover(r:Request) {
		if (r.retries >= retries) {
			endSession('error');
			return;
		}
		// Repeat the request and the preceding ones without response, unless a repetition is outstanding
		for (q in inflight)
			if (q.rid <= r.rid && q.response == null && (q.outstanding == 0 || q.retries == 0)) {
				q.retries++;
				post(q);
			}
	}

	function process(r:Request, body:XML) {
		final type = body.get('type');
		if (sid == null && type != 'terminate') {
			// Session creation response
			sid = body.get('sid');
			if (sid == null) {
				endSession('invalid session creation response');
				return;
			}
			creating = false;
			wait = intAttr(body, 'wait') ?? wait;
			hold = intAttr(body, 'hold') ?? hold;
			requests = intAttr(body, 'requests');
			polling = intAttr(body, 'polling');
			inactivity = intAttr(body, 'inactivity');
			maxpause = intAttr(body, 'maxpause');
			if (terminating) {
				// The stream was ended before the session was created
				terminating = false;
				terminate();
				return;
			}
		}
		if (type == 'terminate') {
			// Payloads (e.g. the stream error) are delivered first, nothing is sent any more
			terminating = true;
			deliver(body);
			final condition = body.get('condition');
			if (condition == 'see-other-uri' && body.has('uri'))
				endSession(null, body.get('uri'));
			else
				endSession(condition);
			return;
		}
		deliver(body);
		if (sid == null)
			return;
		if (terminating) {
			if (r.terminate || inflight.length == 0)
				endSession(null);
			return;
		}
		if (paused)
			return;
		// Keep a request pending, unless polling
		if (!flush() && inflight.length == 0 && hold > 0)
			send(createBody());
	}

	function deliver(body:XML) {
		for (e in body.elements) {
			if (sid == null)
				// The session ended while delivering
				return;
			stream.recv(e.toString());
		}
	}

	/**
		Ends the session and the stream: `onError` with the `condition` if the session failed,
		`Stream.onRedirect` with `uri` if the connection manager redirected, then `Stream.onEnd`.
	**/
	function endSession(?condition:String, ?uri:String) {
		if (sid == null && !creating)
			return;
		reset();
		if (condition != null)
			onError(condition);
		if (uri != null)
			stream.onRedirect(uri);
		stream.recv('</stream:stream>');
	}

	function reset() {
		sid = null;
		creating = false;
		terminating = false;
		paused = false;
		queue = [];
		inflight = [];
		keys = null;
		requests = null;
		polling = null;
		inactivity = null;
		maxpause = null;
	}

	static function intAttr(xml:XML, name:String):Null<Int> {
		final v = xml.get(name);
		return (v == null) ? null : Std.parseInt(v);
	}
}
