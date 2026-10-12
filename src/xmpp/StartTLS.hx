package xmpp;

#if python
/**
	TLS socket on python, returned by `StartTLS.upgrade`.
**/
class PythonTLSSocket extends sys.net.Socket {
	public inline function handshake() {
		python.Syntax.code('{0}.do_handshake()', __s);
	}
}
#end

#if (sys || lua)
/**
	TLS socket returned by `StartTLS.upgrade` (`sys.ssl.Socket`, or `PythonTLSSocket` on python).
**/
typedef SSLSocket =
	#if python
	xmpp.StartTLS.PythonTLSSocket;
	#elseif (cpp || hl || lua || neko)
	sys.ssl.Socket;
	#elseif (macro || eval)
	sys.ssl.Socket;
	#else
	Any; // upgrade is not supported on this target
	#end
#elseif nodejs
#elseif doc_gen
#end

/**
	Secure the stream with Transport Layer Security (TLS).

	Flow:
	1. Check the stream features with `isOffered` (and `isRequired`).
	2. Call `startTLS`; on success upgrade the socket with `upgrade` (and `handshake()` on sys targets).
	3. Restart the stream (`client.Stream.start`) over the TLS socket.

	Never continue without TLS (e.g. if TLS is not offered) to authenticate:
	an attacker can remove the offer from the features to read the credentials (downgrade attack).

	Channel binding (`SCRAM-*-PLUS` mechanisms) is not supported.

	[RFC 6120 5: STARTTLS Negotiation](https://xmpp.org/rfcs/rfc6120.html#tls)
**/
class StartTLS {
	public static inline var XMLNS = 'urn:ietf:params:xml:ns:xmpp-tls';

	/**
		Returns `true` if the stream features offer STARTTLS.
	**/
	public static function isOffered(features:Null<XML>):Bool
		return getFeature(features) != null;

	/**
		Returns `true` if the stream features mark STARTTLS as required.
	**/
	public static function isRequired(features:Null<XML>):Bool {
		final e = getFeature(features);
		return e != null && e.elements.findElement("required") != null;
	}

	static function getFeature(features:Null<XML>):Null<XML>
		return (features == null) ? null : features.elements.first(e -> e.name == "starttls" && e.is(XMLNS));

	/**
		Ask to start TLS negotiation.

		`callback` is called with `true` if the server is ready (`<proceed/>`), `false` otherwise
		(`<failure/>` or any other response); after a failure the server closes the stream.
	**/
	public static function startTLS(stream:Stream, callback:(success:Bool) -> Void) {
		stream.input = str -> {
			var xml = try Xml.parse(str).firstElement() catch (e) {
				callback(false);
				return;
			}
			callback((xml.get("xmlns") == XMLNS) ? switch xml.nodeName {
				case 'proceed': true;
				case _: false;
			} : false);
		};
		stream.send(XML.create('starttls').set('xmlns', XMLNS));
	}

	#if (macro || eval || cpp || hl || lua || neko || python)
	/**
		Upgrades a `sys.net.Socket` to `sys.ssl.Socket`.

		The server certificate must be valid for `servername`, which should be the XMPP domain
		([RFC 6120 13.7.2](https://xmpp.org/rfcs/rfc6120.html#security-certificates-validation)).
		If omitted, the name of `host` is used.
		Verification happens on `handshake()`, which throws if it fails.

		On lua the certificate is **not** verified, since the lua ssl socket does not support it.
	**/
	@:access(sys.net.Socket)
	public static function upgrade(sock:sys.net.Socket, host:sys.net.Host, ?servername:String):SSLSocket {
		final servername = servername ?? host.host;
		#if (macro || eval)
		final s = new sys.ssl.Socket();
		s.socket = sock.socket;
		s.conf = s.buildConfig(false);
		s.ssl = new mbedtls.Ssl();
		s.ssl.setup(s.conf);
		sys.ssl.Mbedtls.setSocket(s.ssl, s.socket);
		s.handshakeDone = false;
		if (s.hostname == null)
			s.hostname = servername;
		if (s.hostname != null)
			s.ssl.set_hostname(s.hostname);
		#elseif python
		// verifies the certificate and hostname (python >= 3.4); called directly to not require the python_version define
		final ctx:Dynamic = python.Syntax.code("__import__('ssl').create_default_context()");
		final s = new PythonTLSSocket();
		s.__s = ctx.wrap_socket(sock.__s, false, false, true, servername);
		s.__rebuildIoStreams();
		#end

		#if cpp
		final s = new sys.ssl.Socket();
		s.__s = sock.__s;
		s.conf = s.buildSSLConfig(false);
		s.ssl = cpp.NativeSsl.ssl_new(s.conf);
		cpp.NativeSsl.ssl_set_socket(s.ssl, s.__s);
		s.setHostname(servername);
		cpp.NativeSsl.ssl_set_hostname(s.ssl, s.hostname);
		s.handshakeDone = false;
		#elseif hl
		final s = new sys.ssl.Socket();
		s.__s = sock.__s;
		s.conf = s.buildConfig(false);
		s.ssl = new sys.ssl.Context(s.conf);
		s.ssl.setSocket(s.__s);
		s.hostname = servername;
		s.ssl.setHostname(@:privateAccess servername.toUtf8());
		s.handshakeDone = false;
		#elseif neko
		final s = new sys.ssl.Socket();
		s.__s = sock.__s;
		s.ctx = s.buildSSLContext(false);
		s.ssl = sys.ssl.Socket.ssl_new(s.ctx);
		sys.ssl.Socket.ssl_set_socket(s.ssl, s.__s);
		s.setHostname(servername);
		sys.ssl.Socket.ssl_set_hostname(s.ssl, untyped servername.__s);
		s.handshakeDone = false;
		#elseif lua
		final s = new sys.ssl.Socket();
		s._sslSocket = s.wrap(sock._socket);
		s.input = new sys.net.SocketInput(s._sslSocket);
		s.output = new sys.net.SocketOutput(s._sslSocket);
		s.handshake();
		#end
		// s.handshake();
		return s;
	}

	#elseif nodejs
	/**
		Upgrades a `js.node.net.Socket` to `js.node.tls.TLSSocket`.

		The server certificate is verified and must be valid for `servername`, which should be the XMPP domain
		([RFC 6120 13.7.2](https://xmpp.org/rfcs/rfc6120.html#security-certificates-validation)).
		Verification failures are emitted as `error` event, a successful handshake as `secureConnect` event.
	**/
	public static function upgrade(sock:js.node.net.Socket, servername:String, ?options:js.node.Tls.TlsConnectOptions):js.node.tls.TLSSocket {
		if (options == null)
			options = {};
		options.socket = sock;
		if (options.servername == null)
			options.servername = servername;
		return js.node.Tls.connect(options);
	}
	#end
}
