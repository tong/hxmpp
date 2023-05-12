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

    //#if sys
    #if (cpp||hl||neko||python)

    @:access(sys.net.Socket)
    public static function upgrade(sock: sys.net.Socket, host: sys.net.Host) : SSLSocket {

        #if python
        final ctx = python.lib.Ssl.create_default_context(python.lib.ssl.Purpose.SERVER_AUTH);
        final s = new xmpp.Socket();
        s.__s = ctx.wrap_socket(sock.__s, false, true, true, host.host);
        s.__rebuildIoStreams();
        #else
        final s = new sys.ssl.Socket();
        s.__s = sock.__s;
        #else #error 'STARTTLS not implemented'
        #end

        #if cpp
        s.conf = s.buildSSLConfig(false);
		s.ssl = cpp.NativeSsl.ssl_new(s.conf);
		s.handshakeDone = false;
		cpp.NativeSsl.ssl_set_socket(s.ssl, s.__s);
		if (s.hostname == null)
		    s.hostname = host.host;
		if (s.hostname != null)
			cpp.NativeSsl.ssl_set_hostname(s.ssl, s.hostname);

        #elseif hl
        //TODO:
        s.handshakeDone = false;
		s.hostname = host.host;
        s.ssl.setHostname(@:privateAccess host.host.toUtf8());

        #elseif neko
        s.ctx = s.buildSSLContext(false);
        s.ssl = sys.ssl.Socket.ssl_new(s.ctx);
        sys.ssl.Socket.ssl_set_socket(s.ssl, s.__s);
        s.handshakeDone = false;
		if (s.hostname == null)
		    s.hostname = host.host;
		if (s.hostname != null)
            sys.ssl.Socket.ssl_set_hostname(s.ssl, untyped s.hostname.__s);
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

