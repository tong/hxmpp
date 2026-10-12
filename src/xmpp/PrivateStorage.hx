package xmpp;

import xmpp.IQ;

/**
	One or more elements to store, all qualified by the same namespace.
**/
abstract PrivateStorageData(Array<XML>) from Array<XML> to Array<XML> {
	@:from static inline function fromXML(xml:XML):PrivateStorageData
		return [xml];
}

/**
	Store any arbitrary XML on the server.

	Rules:
	- The stored element MUST be qualified by its own namespace, otherwise the server returns `not-acceptable`.
	- Some servers reject reserved namespaces (starting with `jabber:` or `http://jabber.org/`, or `vcard-temp`).
	- This protocol is historical: for new data prefer private PEP nodes
	  ([XEP-0223](https://xmpp.org/extensions/xep-0223.html)) using `PubSub`.

	[XEP-0049: Private XML Storage](https://xmpp.org/extensions/xep-0049.html)
**/
@xep(49)
class PrivateStorage {
	public static inline var XMLNS = "jabber:iq:private";

	/**
		Retrieve private data stored on the server.

		`data` is an (empty) element qualified by the namespace of the data, e.g. `<prefs xmlns="example:prefs"/>`.
		Use `getData` to read the stored element from the result.
	**/
	public static inline function getPrivateStorage(stream:Stream, data:XML, handler:Response<Payload>->Void):IQ
		return stream.get(Payload.create(XMLNS).append(data), handler);

	/**
		Store private data on the server: one element, or multiple elements qualified by the same namespace.
	**/
	public static function setPrivateStorage(stream:Stream, data:PrivateStorageData, handler:Response<Payload>->Void):IQ {
		final query = Payload.create(XMLNS);
		for (e in (data : Array<XML>))
			query.append(e);
		return stream.set(query, handler);
	}

	/**
		Returns the stored element of a `getPrivateStorage` result, or `null`.
	**/
	@:noUsing
	public static function getData(payload:Null<Payload>):Null<XML>
		return (payload == null) ? null : payload.firstElement;
}
