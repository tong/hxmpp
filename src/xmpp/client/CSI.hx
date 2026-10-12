package xmpp.client;

/**
	Indicate active/inactive state.

	It is common for IM clients to be logged in and 'online' even while the user is not interacting with the application.
	This protocol allows the client to indicate to the server when the user is not actively using the client, allowing the server to optimise traffic to the client accordingly. This can save bandwidth and resources on both the client and server.

	- The server announces support in the stream features after authentication (see `isOffered`);
	  sending the state to a server without support may close the stream.
	- The initial state is active.
	- The state is independent of the presence: contacts are not informed.
	- While inactive the server may delay or batch traffic (e.g. presence updates) until the client is active again.
	- The server does not respond.

	[XEP-0352: Client State Indication](https://xmpp.org/extensions/xep-0352.html)
**/
@xep(352)
class CSI {
	public static inline var XMLNS = "urn:xmpp:csi:0";

	/**
		Returns `true` if the stream features announce client state indication.
	**/
	@:noUsing
	public static function isOffered(features:Null<XML>):Bool
		return features != null && features.elements.first(e -> e.name == "csi" && e.is(XMLNS)) != null;

	/**
		Indicate to the server whether the user is actively using the client.

		Nothing is sent (`null` is returned) if the stream features of the server are known and do not offer it.
	**/
	public static function csi(stream:xmpp.client.Stream, active = true):Null<XML> {
		if (stream.serverFeatures != null && !isOffered(stream.serverFeatures))
			return null;
		return stream.send(XML.create(active ? "active" : "inactive").set("xmlns", XMLNS));
	}

	/**
		Indicate that the user is actively using the client.
	**/
	public static inline function setActive(stream:xmpp.client.Stream):Null<XML>
		return csi(stream, true);

	/**
		Indicate that the user is not actively using the client.
	**/
	public static inline function setInactive(stream:xmpp.client.Stream):Null<XML>
		return csi(stream, false);
}
