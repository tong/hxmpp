package xmpp.client;

/**
	Indicate active/inactive state.

	It is common for IM clients to be logged in and 'online' even while the user is not interacting with the application.  
	This protocol allows the client to indicate to the server when the user is not actively using the client, allowing the server to optimise traffic to the client accordingly. This can save bandwidth and resources on both the client and server.

	[XEP-0352: Client State Indication](https://xmpp.org/extensions/xep-0352.html)
**/
@xep(352)
class CSI {
	public static inline var XMLNS = "urn:xmpp:csi:0";

	/**
		Indicate to the server when the user is (not) actively using the client.
	**/
	public static inline function csi(stream:xmpp.client.Stream, active = true):XML
		return stream.send(XML.create(active ? "active" : "inactive").set("xmlns", XMLNS));
}
