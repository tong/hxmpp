package xmpp;

#if python
class Socket extends sys.net.Socket {
    public inline function handshake() {
        trace('TODO handshake');
        //SSLSocket.do_handshake()
    }
}
#end

private typedef SSLSocket =
    #if python xmpp.Socket;
    #elseif (cpp||hl||neko) sys.ssl.Socket;
    #elseif macro sys.ssl.Socket;
    #end

/**

    XMPP includes a method for securing the stream from tampering and eavesdropping.
    This channel encryption method makes use of the Transport Layer Security (TLS) protocol [TLS], along with a "STARTTLS" extension.

	https://xmpp.org/rfcs/rfc3920.html#tls
**/
class StartTLS {

	public static inline var XMLNS = 'urn:ietf:params:xml:ns:xmpp-tls';

	public static function startTLS(stream:Stream, callback:(success:Bool) -> Void) {
		stream.input = str -> {
            var xml = try XML.parse(str) catch(e:Dynamic) {
                trace(e);
                callback(false);
                return;
            }
            callback((xml.xmlns == XMLNS) ? switch xml.name {
                case 'proceed': true;
                case _: false;
            } : false);
		};
		stream.send(XML.create('starttls').set('xmlns', XMLNS));
	}

    //TODO: #if sys
    #if (macro||cpp||hl||neko||python)

    @:access(sys.net.Socket)
    public static function upgrade(sock: sys.net.Socket, host: sys.net.Host) : SSLSocket {

        #if macro
        final s = new sys.ssl.Socket();
        s.socket = sock.socket;
		s.ssl = new mbedtls.Ssl();
        sys.ssl.Mbedtls.setSocket(s.ssl, s.socket);
		s.handshakeDone = false;
		if (s.hostname == null)
		    s.hostname = host.host;
		if (s.hostname != null)
			s.ssl.set_hostname(s.hostname);
        #elseif python
        final ctx = python.lib.Ssl.create_default_context(python.lib.ssl.Purpose.SERVER_AUTH);
        final s = new xmpp.Socket();
        s.__s = ctx.wrap_socket(sock.__s, false, true, true, host.host);
        s.__rebuildIoStreams();
        #else
        final s = new sys.ssl.Socket();
        s.__s = sock.__s;
        #else
            #error 'STARTTLS not implemented'
        #end

        #if cpp
        s.conf = s.buildSSLConfig(false);
		s.ssl = cpp.NativeSsl.ssl_new(s.conf);
		cpp.NativeSsl.ssl_set_socket(s.ssl, s.__s);
        s.setHostname(host.host);
		cpp.NativeSsl.ssl_set_hostname(s.ssl, s.hostname);
		s.handshakeDone = false;

        #elseif hl
        s.conf = s.buildConfig(false);
		s.ssl = new sys.ssl.Context(s.conf);
        s.ssl.setSocket(s.__s);
		s.hostname = host.host;
        s.ssl.setHostname(@:privateAccess host.host.toUtf8());
        s.handshakeDone = false;

        #elseif neko
        s.ctx = s.buildSSLContext(false);
        s.ssl = sys.ssl.Socket.ssl_new(s.ctx);
        sys.ssl.Socket.ssl_set_socket(s.ssl, s.__s);
        s.setHostname(host.host);
        sys.ssl.Socket.ssl_set_hostname(s.ssl, untyped host.host.__s);
        //sys.ssl.Socket.ssl_set_hostname(s.ssl, untyped s.hostname.__s);
        s.handshakeDone = false;
        #end
        //s.handshake();
        return s;
    }

    #elseif nodejs

    public static inline function upgrade(sock: js.node.net.Socket, ?options: js.node.tls.TLSSocket.TLSSocketOptions) : js.node.tls.TLSSocket {
        return new js.node.tls.TLSSocket(sock, options);
    }

    #end
}

