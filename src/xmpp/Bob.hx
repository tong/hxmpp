package xmpp;

/**
	Exchange small amounts of binary data, e.g. images referenced in messages.

	[XEP-0231: Bits of Binary](https://xmpp.org/extensions/xep-0231.html)
**/
@xep(231)
class Bob {
	public static inline var XMLNS = 'urn:xmpp:bob';

	/**
		Request the data with the content id `cid` from the entity `jid`.
	**/
	public static function requestBob(stream:Stream, jid:String, cid:String, handler:Response<XML>->Void):IQ {
		return stream.get(XML.create('data').set('xmlns', XMLNS).set('cid', cid), jid, handler);
	}
}
