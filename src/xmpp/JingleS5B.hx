package xmpp;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import xmpp.IQ;
import xmpp.Jingle;
import xmpp.JingleS5BNetwork;

/**
	Type of a SOCKS5 bytestream candidate.
**/
enum abstract JingleS5BCandidateType(String) from String to String {
	/** Direct connection using the given interface **/
	var direct;

	/** Direct connection using NAT assisting technologies like NAT-PMP or UPnP-IGD **/
	var assisted;

	/** Tunnel protocols such as Teredo **/
	var tunnel;

	/** SOCKS5 relay **/
	var proxy;
}

/**
	A host offered for a SOCKS5 bytestream.
**/
typedef JingleS5BCandidate = {
	/** Candidate id **/
	var cid:String;

	var host:String;

	/** The entity hosting the candidate (the offering party, or the proxy) **/
	var jid:String;

	var port:Int;
	var priority:Int;
	var type:JingleS5BCandidateType;
}

/**
	A SOCKS5 bytestreams proxy ([XEP-0065](https://xmpp.org/extensions/xep-0065.html) streamhost).
**/
typedef JingleS5BStreamhost = {
	var jid:String;
	var host:String;
	var port:Int;
}

/**
	A parsed SOCKS5 bytestreams `<transport/>` element.
**/
typedef JingleS5BTransportInfo = {
	var sid:String;
	var ?dstaddr:String;
	var ?mode:String;
	var candidates:Array<JingleS5BCandidate>;

	/** `transport-info`: the candidate the peer connected to **/
	var ?candidateUsed:String;

	/** `transport-info`: the peer could not connect to any candidate **/
	var candidateError:Bool;

	/** `transport-info`: the proxy candidate has been activated **/
	var ?activated:String;

	/** `transport-info`: the peer could not connect to the proxy **/
	var proxyError:Bool;
}

/**
	Network configuration of SOCKS5 bytestreams.
**/
typedef JingleS5BConfig = {
	/** Network access, e.g. `JingleS5BNodeNetwork` on nodejs; without network only in-band bytestreams can be used **/
	var ?network:JingleS5BNetwork;

	/** Offer direct connections (listen for connections of the peer), default `true` **/
	var ?direct:Bool;

	/** Addresses offered for direct connections, by default `network.addresses()` **/
	var ?hosts:Array<String>;

	/** SOCKS5 proxies to offer (see `JingleS5B.requestStreamhost`) **/
	var ?proxies:Array<JingleS5BStreamhost>;
}

/**
	An established SOCKS5 bytestream. Data received before `onData` is set is buffered.

	Set `onClose` before `onData`.
**/
class JingleS5BStream {
	/** Called once the connection is closed (after all data has been passed to `onData`) **/
	public dynamic function onClose() {}

	/** Called with received data **/
	public var onData(default, set):Null<Bytes->Void>;

	public var closed(default, null) = false;

	final connection:JingleS5BConnection;
	var buffer:Null<BytesBuffer>;

	@:allow(xmpp.JingleS5B)
	function new(connection:JingleS5BConnection, ?pending:Bytes) {
		this.connection = connection;
		if (pending != null && pending.length > 0) {
			buffer = new BytesBuffer();
			buffer.add(pending);
		}
		connection.onData = data -> {
			if (onData != null)
				onData(data);
			else {
				buffer ??= new BytesBuffer();
				buffer.add(data);
			}
		}
		connection.onClose = () -> {
			if (closed)
				return;
			closed = true;
			if (onData != null)
				onClose();
		}
	}

	function set_onData(f:Null<Bytes->Void>) {
		onData = f;
		if (f != null && buffer != null) {
			final data = buffer.getBytes();
			buffer = null;
			if (data.length > 0)
				f(data);
		}
		if (f != null && closed)
			onClose();
		return f;
	}

	public inline function write(data:Bytes)
		if (!closed)
			connection.write(data);

	public function close() {
		if (closed)
			return;
		closed = true;
		connection.close();
	}
}

/**
	Transport of Jingle sessions over SOCKS5 bytestreams: a direct TCP connection between the peers,
	or a connection through a SOCKS5 proxy.

	Both parties offer candidates (their own addresses and proxies), try to connect to the candidates of the peer
	(in order of priority) and report the result (`candidate-used` or `candidate-error`).
	The nominated candidate is the used candidate with the highest priority (on equal priority the initiator's choice).
	If no connection could be established, the initiator falls back to another transport (`transport-replace`).

	Rules:
	- Candidates expose IP addresses: offer them only to entities the user approved (e.g. by accepting the session).
	- The connection is not encrypted.

	[XEP-0260: Jingle SOCKS5 Bytestreams Transport Method](https://xmpp.org/extensions/xep-0260.html)
	[XEP-0065: SOCKS5 Bytestreams](https://xmpp.org/extensions/xep-0065.html)
**/
@xep(260)
class JingleS5B {
	public static inline var XMLNS = "urn:xmpp:jingle:transports:s5b:1";
	public static inline var XMLNS_BYTESTREAMS = "http://jabber.org/protocol/bytestreams";

	/** Called with the established bytestream **/
	public dynamic function onReady(stream:JingleS5BStream) {}

	/** Called if no bytestream could be established **/
	public dynamic function onFailed(reason:String) {}

	public final session:JingleSession;

	/** Bytestream session id **/
	public final sid:String;

	/** Candidates offered by this entity **/
	public var candidates(default, null):Array<JingleS5BCandidate> = [];

	/** Candidates offered by the peer **/
	public var remoteCandidates(default, null):Array<JingleS5BCandidate> = [];

	/** The nominated candidate, once negotiated **/
	public var nominated(default, null):Null<JingleS5BCandidate>;

	final contentName:String;
	final creator:JingleCreator;
	final config:JingleS5BConfig;
	final network:Null<JingleS5BNetwork>;
	final incoming = new Array<JingleS5BStream>();
	var stopListening:Null<() -> Void>;
	var remoteDstaddr:Null<String>;

	/** Result of the connection attempts to the peer's candidates **/
	var local:Null<{candidate:JingleS5BCandidate, stream:JingleS5BStream}>;

	var localDone = false;

	/** The cid of the own candidate the peer connected to **/
	var remoteUsed:Null<String>;

	var remoteDone = false;
	var activated:Null<String>;
	var awaitActivation:Null<String>;
	var stream:Null<JingleS5BStream>;
	var finished = false;
	var closed = false;

	/**
		Creates the transport of the content `contentName` of `session`; `sid` is the bytestream session id
		(the responder uses the one of the initiator's transport).
	**/
	public function new(session:JingleSession, contentName:String, creator:JingleCreator, ?config:JingleS5BConfig, ?sid:String) {
		this.session = session;
		this.contentName = contentName;
		this.creator = creator;
		this.config = config ?? {};
		this.network = this.config.network;
		this.sid = sid ?? xmpp.Stream.makeRandomId();
	}

	var ownJid(get, never):String;

	inline function get_ownJid():String
		return session.jingle.stream.jid ?? "";

	/** DST.ADDR of the own candidates: SHA1(sid + own jid + peer jid) **/
	public var dstaddr(get, never):String;

	inline function get_dstaddr():String
		return createDstaddr(sid, ownJid, session.peer);

	/**
		Gathers the own candidates (listens for direct connections), then calls `callback`.
		`remote` (the transport of the initiator) excludes candidates already offered by the peer.
	**/
	public function prepare(?remote:XML, callback:() -> Void) {
		final info = (remote == null) ? null : parseTransport(remote);
		final offered = (info == null) ? [] : [for (c in info.candidates) c.host + ":" + c.port];
		function add(c:JingleS5BCandidate)
			if (!offered.contains(c.host + ":" + c.port))
				candidates.push(c);
		function addProxies() {
			if (config.proxies != null)
				for (i => p in config.proxies)
					add({
						cid: xmpp.Stream.makeRandomId(8),
						host: p.host,
						jid: p.jid,
						port: p.port,
						priority: priority(proxy, 65535 - i),
						type: proxy
					});
			callback();
		}
		if (network == null || config.direct == false) {
			addProxies();
			return;
		}
		stopListening = network.listen(handleConnection, (error, port) -> {
			if (closed)
				return;
			if (error == null) {
				final hosts = config.hosts ?? network.addresses();
				for (i => host in hosts)
					add({
						cid: xmpp.Stream.makeRandomId(8),
						host: host,
						jid: ownJid,
						port: port,
						priority: priority(direct, 65535 - i),
						type: direct
					});
			}
			addProxies();
		});
	}

	/**
		Returns the own `<transport/>` with the candidates.
	**/
	public function createTransport():XML {
		final xml = XML.create("transport").set("xmlns", XMLNS).set("sid", sid);
		if (session.isInitiator)
			xml.set("mode", "tcp");
		if (candidates.filter(c -> c.type == proxy).length > 0)
			xml.set("dstaddr", dstaddr);
		for (c in candidates)
			xml.append(createCandidate(c));
		return xml;
	}

	/**
		Starts connecting to the candidates of the peer's `transport`.
	**/
	public function start(transport:XML) {
		final info = parseTransport(transport);
		if (info == null || info.sid != sid) {
			fail("invalid transport");
			return;
		}
		remoteCandidates = info.candidates.copy();
		remoteCandidates.sort((a, b) -> b.priority - a.priority);
		remoteDstaddr = info.dstaddr ?? createDstaddr(sid, session.peer, ownJid);
		tryCandidate(0);
	}

	/**
		Handles a `<transport/>` of a `transport-info` request.
	**/
	public function handleInfo(transport:XML) {
		final info = parseTransport(transport);
		if (info == null || info.sid != sid || closed)
			return;
		if (info.candidateUsed != null && !remoteDone) {
			remoteDone = true;
			remoteUsed = info.candidateUsed;
			nominate();
		} else if (info.candidateError && !remoteDone) {
			remoteDone = true;
			nominate();
		} else if (info.activated != null) {
			activated = info.activated;
			if (awaitActivation == info.activated)
				ready(local.stream);
		} else if (info.proxyError) {
			fail("proxy-error");
		}
	}

	/**
		Closes all connections.
	**/
	public function close() {
		if (closed)
			return;
		closed = true;
		finished = true;
		if (stopListening != null)
			stopListening();
		for (s in incoming)
			s.close();
		if (local != null)
			local.stream.close();
		if (stream != null)
			stream.close();
	}

	function tryCandidate(i:Int) {
		if (closed || localDone)
			return;
		final c = remoteCandidates[i];
		final used = (remoteUsed == null) ? null : candidates.filter(c -> c.cid == remoteUsed)[0];
		if (c == null || network == null || (used != null && c.priority < used.priority)) {
			// no candidate left, or only candidates with a lower priority than the one used by the peer
			localDone = true;
			sendInfo(XML.create("candidate-error"));
			nominate();
			return;
		}
		network.connect(c.host, c.port, (error, connection) -> {
			if (closed) {
				if (connection != null)
					connection.close();
				return;
			}
			if (error != null) {
				tryCandidate(i + 1);
				return;
			}
			socks5Connect(connection, remoteDstaddr, (error, stream) -> {
				if (closed || localDone) {
					if (stream != null)
						stream.close();
					return;
				}
				if (error != null) {
					connection.close();
					tryCandidate(i + 1);
					return;
				}
				localDone = true;
				local = {candidate: c, stream: stream};
				sendInfo(XML.create("candidate-used").set("cid", c.cid));
				nominate();
			});
		});
	}

	function handleConnection(connection:JingleS5BConnection) {
		if (closed || finished) {
			connection.close();
			return;
		}
		socks5Accept(connection, addr -> addr == dstaddr, (error, addr, stream) -> {
			if (error == null) {
				if (closed || finished)
					stream.close();
				else
					incoming.push(stream);
			}
		});
	}

	function nominate() {
		if (finished || !localDone || !remoteDone)
			return;
		final ours = (local == null) ? null : local.candidate;
		final theirs = (remoteUsed == null) ? null : candidates.filter(c -> c.cid == remoteUsed)[0];
		if (ours == null && theirs == null) {
			fail("no candidate");
			return;
		}
		// the candidate this entity connected to, unless the peer's has a higher priority (on equal priority: the initiator's choice)
		final useOurs = (theirs == null)
			|| (ours != null && (ours.priority > theirs.priority || (ours.priority == theirs.priority && session.isInitiator)));
		finished = true;
		if (stopListening != null) {
			stopListening();
			stopListening = null;
		}
		if (useOurs) {
			nominated = ours;
			for (s in incoming)
				s.close();
			if (ours.type == proxy) {
				// the peer activates its proxy
				awaitActivation = ours.cid;
				if (activated == ours.cid)
					ready(local.stream);
			} else
				ready(local.stream);
		} else {
			nominated = theirs;
			if (local != null)
				local.stream.close();
			if (theirs.type == proxy) {
				for (s in incoming)
					s.close();
				activateProxy(theirs);
			} else {
				final open = incoming.filter(s -> !s.closed);
				if (open.length == 0) {
					fail("no connection");
					return;
				}
				for (s in open.slice(1))
					s.close();
				ready(open[0]);
			}
		}
	}

	function activateProxy(c:JingleS5BCandidate) {
		function proxyError(reason:String) {
			sendInfo(XML.create("proxy-error"));
			fail(reason);
		}
		if (network == null) {
			proxyError("no network");
			return;
		}
		network.connect(c.host, c.port, (error, connection) -> {
			if (closed) {
				if (connection != null)
					connection.close();
				return;
			}
			if (error != null) {
				proxyError(error);
				return;
			}
			socks5Connect(connection, dstaddr, (error, stream) -> {
				if (error != null) {
					connection.close();
					proxyError(error);
					return;
				}
				this.stream = stream;
				activate(session.jingle.stream, c.jid, sid, session.peer, res -> {
					if (closed)
						return;
					if (!res.ok()) {
						proxyError(res.error.condition);
						return;
					}
					sendInfo(XML.create("activated").set("cid", c.cid));
					ready(stream);
				});
			});
		});
	}

	function ready(stream:JingleS5BStream) {
		if (closed)
			return;
		this.stream = stream;
		awaitActivation = null;
		onReady(stream);
	}

	function fail(reason:String) {
		if (closed)
			return;
		close();
		onFailed(reason);
	}

	function sendInfo(e:XML)
		session.send(transport_info, [
			{
				creator: creator,
				name: contentName,
				transport: XML.create("transport").set("xmlns", XMLNS).set("sid", sid).append(e)
			}
		]);

	/**
		Returns the priority of a candidate: `(2^16) * type preference + local preference` (0-65535).
	**/
	@:noUsing
	public static function priority(type:JingleS5BCandidateType, localPreference = 0):Int {
		final preference = switch type {
			case direct: 126;
			case assisted: 120;
			case tunnel: 110;
			case proxy: 10;
			case _: 0;
		}
		return (preference << 16) + localPreference;
	}

	/**
		Returns the SOCKS5 DST.ADDR of a bytestream: the hex SHA1 of `sid + requester + target`.
	**/
	@:noUsing
	public static inline function createDstaddr(sid:String, requester:String, target:String):String
		return haxe.crypto.Sha1.encode(sid + requester + target);

	/**
		Creates a `<candidate/>` element.
	**/
	@:noUsing
	public static function createCandidate(c:JingleS5BCandidate):XML
		return XML.create("candidate")
			.set("cid", c.cid)
			.set("host", c.host)
			.set("jid", c.jid)
			.set("port", Std.string(c.port))
			.set("priority", Std.string(c.priority))
			.set("type", c.type);

	/**
		Parses a SOCKS5 bytestreams `<transport/>` element, returns `null` if it is none.
	**/
	@:noUsing
	public static function parseTransport(xml:Null<XML>):Null<JingleS5BTransportInfo> {
		if (xml == null || !xml.is(XMLNS) || !xml.has("sid"))
			return null;
		final info:JingleS5BTransportInfo = {
			sid: xml.get("sid"),
			candidates: [],
			candidateError: false,
			proxyError: false
		};
		if (xml.has("dstaddr"))
			info.dstaddr = xml.get("dstaddr");
		if (xml.has("mode"))
			info.mode = xml.get("mode");
		for (e in xml.elements) {
			switch e.name {
				case "candidate":
					final port = Std.parseInt(e.get("port"));
					final priority = Std.parseInt(e.get("priority"));
					if (!e.has("cid") || !e.has("host") || !e.has("jid") || port == null || priority == null)
						continue;
					info.candidates.push({
						cid: e.get("cid"),
						host: e.get("host"),
						jid: e.get("jid"),
						port: port,
						priority: priority,
						type: e.get("type") ?? direct
					});
				case "candidate-used" if (e.has("cid")):
					info.candidateUsed = e.get("cid");
				case "candidate-error":
					info.candidateError = true;
				case "activated" if (e.has("cid")):
					info.activated = e.get("cid");
				case "proxy-error":
					info.proxyError = true;
				case _:
			}
		}
		return info;
	}

	/**
		Requests the network address of the SOCKS5 bytestreams proxy `jid` (e.g. `proxy.example.com`),
		use `parseStreamhost` to read the result.
	**/
	public static inline function requestStreamhost(stream:Stream, jid:String, handler:Response<XML>->Void):IQ
		return stream.get(Payload.create(XMLNS_BYTESTREAMS), jid, handler);

	/**
		Parses the `<streamhost/>` of a proxy query result.
	**/
	@:noUsing
	public static function parseStreamhost(payload:Null<XML>):Null<JingleS5BStreamhost> {
		if (payload == null)
			return null;
		final e = payload.elements.named("streamhost")[0];
		if (e == null || !e.has("jid") || !e.has("host"))
			return null;
		final port = Std.parseInt(e.get("port")) ?? 1080;
		return {jid: e.get("jid"), host: e.get("host"), port: port};
	}

	/**
		Activates the bytestream `sid` at the proxy `jid` to `target`.
	**/
	public static inline function activate(stream:Stream, jid:String, sid:String, target:String, handler:Response<XML>->Void):IQ
		return stream.set(Payload.create(XMLNS_BYTESTREAMS).set("sid", sid).append(XML.create("activate", target)), jid, handler);

	/**
		Performs the SOCKS5 handshake (client) on `connection`, requesting `dstaddr`.
		`callback` is called with an error, or the bytestream.
	**/
	@:noUsing
	public static function socks5Connect(connection:JingleS5BConnection, dstaddr:String, callback:(error:Null<String>, stream:Null<JingleS5BStream>) -> Void) {
		final reader = new Socks5Reader(connection);
		var state = 0;
		var done = false;
		function finish(error:Null<String>) {
			if (done)
				return;
			done = true;
			reader.detach();
			callback(error, (error == null) ? new JingleS5BStream(connection, reader.remaining()) : null);
		}
		connection.onClose = () -> finish("connection closed");
		reader.process = () -> {
			switch state {
				case 0:
					final r = reader.read(2);
					if (r == null)
						return false;
					if (r.get(0) != 5 || r.get(1) != 0) {
						finish("authentication method not accepted");
						return false;
					}
					state = 1;
					connection.write(socks5Request(1, dstaddr));
					return true;
				case 1:
					final reply = reader.readMessage();
					if (reply == null)
						return false;
					if (reply.code != 0) {
						finish('connection refused (${reply.code})');
						return false;
					}
					state = 2;
					finish(null);
					return false;
				case _:
					return false;
			}
		}
		connection.write(Bytes.ofHex("050100"));
	}

	/**
		Performs the SOCKS5 handshake (server) on `connection`: accepts connect requests to an address for which `check` returns `true`.
		`callback` is called with an error, or the requested address and the bytestream.
	**/
	@:noUsing
	public static function socks5Accept(connection:JingleS5BConnection, check:String->Bool,
			callback:(error:Null<String>, dstaddr:Null<String>, stream:Null<JingleS5BStream>) -> Void) {
		final reader = new Socks5Reader(connection);
		var state = 0;
		var done = false;
		function finish(error:Null<String>, ?addr:String) {
			if (done)
				return;
			done = true;
			reader.detach();
			if (error != null)
				connection.close();
			callback(error, addr, (error == null) ? new JingleS5BStream(connection, reader.remaining()) : null);
		}
		connection.onClose = () -> finish("connection closed");
		reader.process = () -> {
			switch state {
				case 0:
					final header = reader.peek(2);
					if (header == null)
						return false;
					final methods = reader.read(2 + header.get(1));
					if (methods == null)
						return false;
					var noAuth = false;
					for (i in 2...methods.length)
						if (methods.get(i) == 0)
							noAuth = true;
					if (methods.get(0) != 5 || !noAuth) {
						connection.write(Bytes.ofHex("05ff"));
						finish("no acceptable authentication method");
						return false;
					}
					state = 1;
					connection.write(Bytes.ofHex("0500"));
					return true;
				case 1:
					final request = reader.readMessage();
					if (request == null)
						return false;
					state = 2;
					if (request.code != 1 || request.address == null || !check(request.address)) {
						// command not supported / connection refused
						connection.write(socks5Request(request.code != 1 ? 7 : 5, request.address ?? ""));
						finish("connection refused");
						return false;
					}
					// the bytestream is set up before the client is informed (and may use it)
					finish(null, request.address);
					connection.write(socks5Request(0, request.address));
					return false;
				case _:
					return false;
			}
		}
	}

	/** A SOCKS5 request (code: command) or reply (code: status) with a domain name address and port 0 **/
	static function socks5Request(code:Int, address:String):Bytes {
		final addr = Bytes.ofString(address);
		final b = new BytesBuffer();
		b.addByte(5);
		b.addByte(code);
		b.addByte(0);
		b.addByte(3);
		b.addByte(addr.length);
		b.add(addr);
		b.addByte(0);
		b.addByte(0);
		return b.getBytes();
	}
}

/**
	Reads the messages of a SOCKS5 handshake from a connection.
**/
private class Socks5Reader {
	public var process:() -> Bool = () -> false;

	final connection:JingleS5BConnection;
	var buffer = Bytes.alloc(0);
	var processing = false;
	var detached = false;

	public function new(connection:JingleS5BConnection) {
		this.connection = connection;
		connection.onData = data -> {
			final b = Bytes.alloc(buffer.length + data.length);
			b.blit(0, buffer, 0, buffer.length);
			b.blit(buffer.length, data, 0, data.length);
			buffer = b;
			if (processing)
				return; // re-entrant call, processed by the running loop
			processing = true;
			while (!detached && process()) {}
			processing = false;
		}
	}

	public function peek(n:Int):Null<Bytes>
		return (buffer.length < n) ? null : buffer.sub(0, n);

	public function read(n:Int):Null<Bytes> {
		if (buffer.length < n)
			return null;
		final r = buffer.sub(0, n);
		buffer = buffer.sub(n, buffer.length - n);
		return r;
	}

	/** Reads a request or reply: VER CODE RSV ATYP ADDR PORT **/
	public function readMessage():Null<{code:Int, address:Null<String>}> {
		if (buffer.length < 5)
			return null;
		final atyp = buffer.get(3);
		final addrLength = switch atyp {
			case 1: 4;
			case 3: 1 + buffer.get(4);
			case 4: 16;
			case _: 0;
		}
		final m = read(4 + addrLength + 2);
		if (m == null)
			return null;
		return {code: m.get(1), address: (atyp == 3) ? m.getString(5, addrLength - 1) : null};
	}

	public function remaining():Bytes {
		final r = buffer;
		buffer = Bytes.alloc(0);
		return r;
	}

	public function detach()
		detached = true;
}
