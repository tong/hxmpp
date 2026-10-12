package xmpp;

import haxe.crypto.Base64;
import haxe.crypto.Sha1;
import haxe.crypto.Sha256;
import haxe.io.Bytes;
import xmpp.IQ;
import xmpp.Response.EResponse;

typedef BobData = {
	/** Content id, `algo+hash@bob.xmpp.org` **/
	var cid:String;

	/** MIME type, e.g. `image/png` **/
	var type:Null<String>;

	/** Suggested time in seconds to cache the data, `0` for no caching **/
	var maxAge:Null<Int>;

	/** The data, `null` for an empty `<data/>` element **/
	var bytes:Null<Bytes>;

	/** `true` if the data was verified against the hash of the cid **/
	var verified:Bool;
}

/**
	Exchange small amounts of binary data, e.g. images referenced in messages.

	Data SHOULD NOT be larger than 8 KiB and only be included directly in a stanza if smaller than about 1 KiB;
	otherwise only send the cid and let the recipient request the data.

	[XEP-0231: Bits of Binary](https://xmpp.org/extensions/xep-0231.html)
**/
@xep(231)
class Bob {
	public static inline var XMLNS = 'urn:xmpp:bob';

	/**
		Returns the content id of `bytes`: `sha1+<hex hash>@bob.xmpp.org`.
	**/
	public static function cid(bytes:Bytes):String
		return 'sha1+${Sha1.make(bytes).toHex()}@bob.xmpp.org';

	/**
		Creates a `<data/>` element containing `bytes` of MIME `type`, with `maxAge` as suggested cache time in seconds.
	**/
	public static function create(bytes:Bytes, type:String, ?maxAge:Int):XML {
		final xml = XML.create('data').set('xmlns', XMLNS).set('cid', cid(bytes)).set('type', type);
		if (maxAge != null)
			xml.set('max-age', Std.string(maxAge));
		xml.text = Base64.encode(bytes);
		return xml;
	}

	/**
		Parses a `<data/>` element.

		Returns `null` if the data does not match the hash of its cid.
		If the hash algorithm is not supported the data is returned with `verified` = `false`.
	**/
	public static function parse(xml:XML):Null<BobData> {
		final cid = xml.get('cid');
		if (cid == null)
			return null;
		final text = xml.text;
		final bytes = (text == null || StringTools.trim(text).length == 0) ? null : try Base64.decode(~/\s+/g.replace(text, '')) catch (e) return null;
		final maxAge = xml.has('max-age') ? Std.parseInt(xml.get('max-age')) : null;
		var verified = false;
		if (bytes != null) {
			final hash = hashOf(cid, bytes);
			if (hash != null) {
				if (hash != cidHash(cid))
					return null;
				verified = true;
			}
		}
		return {
			cid: cid,
			type: xml.get('type'),
			maxAge: maxAge,
			bytes: bytes,
			verified: verified
		};
	}

	/**
		Returns the data included directly in a message or presence stanza.
		Data not matching its cid is omitted.
	**/
	public static function getData(stanza:Stanza):Array<BobData> {
		final r = new Array<BobData>();
		for (e in stanza.properties) {
			if (e.name == 'data' && e.is(XMLNS)) {
				final data = parse(e);
				if (data != null)
					r.push(data);
			}
		}
		return r;
	}

	/**
		Request the data with the content id `cid` from the entity `jid`, use `parse` to read the result.
	**/
	public static function requestBob(stream:Stream, jid:String, cid:String, handler:Response<XML>->Void):IQ {
		return stream.get(XML.create('data').set('xmlns', XMLNS).set('cid', cid), jid, handler);
	}

	/**
		Answer data requests of other entities.

		`lookup` returns the `<data/>` element (see `create`) for a cid, or `null` if unknown (answered with `item-not-found`).
	**/
	public static function handleRequests(stream:Stream, lookup:(cid:String) -> Null<XML>) {
		stream.features.set(XMLNS, (iq, respond) -> {
			if (iq.type != Get) {
				respond(EResponse.Error(new xmpp.Stanza.Error(cancel, bad_request)));
				return;
			}
			final data = lookup(iq.payload.get('cid'));
			respond((data == null) ? EResponse.Error(new xmpp.Stanza.Error(cancel, item_not_found)) : EResponse.Result(data));
		});
	}

	/** Lowercase hex hash of the cid, or `null` if not of the form `algo+hash@bob.xmpp.org` **/
	static function cidHash(cid:String):Null<String> {
		final r = ~/^[^+]+\+([0-9a-fA-F]+)@bob\.xmpp\.org$/;
		return r.match(cid) ? r.matched(1).toLowerCase() : null;
	}

	/** Hex hash of `bytes` with the algorithm of the cid, or `null` if not supported **/
	static function hashOf(cid:String, bytes:Bytes):Null<String> {
		if (cidHash(cid) == null)
			return null;
		return switch cid.substr(0, cid.indexOf('+')).toLowerCase() {
			case 'sha1': Sha1.make(bytes).toHex();
			case 'sha-256': Sha256.make(bytes).toHex();
			case _: null;
		}
	}
}
