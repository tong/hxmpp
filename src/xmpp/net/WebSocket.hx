package xmpp.net;

/**
	XMPP over WebSocket, e.g. for browser clients.

	The connection is made with the WebSocket API of the platform, the stream uses the framing of the WebSocket binding:

		final ws = new js.html.WebSocket('wss://example.com/xmpp-websocket', WebSocket.PROTOCOL);
		final stream = new xmpp.client.Stream('example.com');
		stream.framing = true;
		stream.output = str -> ws.send(str);
		ws.onmessage = e -> stream.recv(e.data);
		ws.onopen = () -> stream.start(features -> {
			// authenticate (no STARTTLS, TLS is provided by wss://)
		});

	Rules:
	- Each WebSocket message is one complete element: pass each message to `recv`, send each `output` as one message.
	- Use `wss://` (TLS) connections; STARTTLS is not used.
	- Whitespace keepalives are not allowed, use `Ping` instead.
	- If the server closes the stream with a `see-other-uri`, `Stream.onRedirect` is called with the new endpoint.
	- After the stream ended (`Stream.onEnd`) close the WebSocket connection.

	The WebSocket endpoint of a domain can be discovered with
	[XEP-0156](https://xmpp.org/extensions/xep-0156.html) (`urn:xmpp:alt-connections:websocket`).

	[RFC 7395: An Extensible Messaging and Presence Protocol (XMPP) Subprotocol for WebSocket](https://www.rfc-editor.org/rfc/rfc7395)
**/
class WebSocket {
	/** WebSocket subprotocol identifier, to be requested in the WebSocket handshake **/
	public static inline var PROTOCOL = 'xmpp';

	/** Namespace of the `<open/>` and `<close/>` elements **/
	public static inline var XMLNS = xmpp.Stream.XMLNS_FRAMING;

	/** Link relation of the WebSocket endpoint in host-meta ([XEP-0156](https://xmpp.org/extensions/xep-0156.html)) **/
	public static inline var REL = 'urn:xmpp:alt-connections:websocket';

	@:noCompletion @:deprecated('Use PROTOCOL')
	public static inline var PROTOCOL_IDENTIFIER = PROTOCOL;

	@:noCompletion @:deprecated('Use XMLNS')
	public static inline var URI = XMLNS;
}
