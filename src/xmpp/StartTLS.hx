package xmpp;

/**

    XMPP includes a method for securing the stream from tampering and eavesdropping.
    This channel encryption method makes use of the Transport Layer Security (TLS) protocol [TLS], along with a "STARTTLS" extension.

	https://xmpp.org/rfcs/rfc3920.html#tls
**/
class StartTLS {

	public static inline var XMLNS = 'urn:ietf:params:xml:ns:xmpp-tls';

	//@:access(xmpp.Stream)
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

    #if (cpp||hl||neko)

    @:access(sys.net.Socket)
    public static function upgrade(sock: sys.net.Socket, host: sys.net.Host) : sys.ssl.Socket {

        final s = new sys.ssl.Socket();
        s.__s = sock.__s;

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
