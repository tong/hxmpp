package xmpp;

import xmpp.IQ;

typedef TEntityTime = {
	/**
		The UTC time according to the responding entity, as [XEP-0082](https://xmpp.org/extensions/xep-0082.html) date-time.
	**/
	utc:String,

	/**
		The entity's time zone offset from UTC, as [XEP-0082](https://xmpp.org/extensions/xep-0082.html) time zone definition (e.g. `-06:00` or `Z`).
	**/
	tzo:String,

	/**
		The `utc` time as date, `null` if invalid.
	**/
	date:Null<Date>,

	/**
		The `tzo` offset in minutes (e.g. `-360`), `null` if invalid.
	**/
	offset:Null<Int>,
}

/**
	Communicate the local time of an entity, including the time in UTC.

	[XEP-0202: Entity Time](https://xmpp.org/extensions/xep-0202.html)
**/
@xep(202)
class EntityTime {
	public static inline var XMLNS = "urn:xmpp:time";

	/**
		Request the time of the entity `jid` (the server if `null`), use `parse` to read the result.
	**/
	public static inline function getEntityTime(stream:Stream, ?jid:String, handler:Response<XML>->Void):IQ {
		return stream.get(Payload.create(XMLNS, "time"), jid ?? stream.domain, handler);
	}

	/**
		Parses a `<time/>` element, returns `null` if `<utc/>` or `<tzo/>` is missing.
	**/
	@:noUsing
	public static function parse(xml:XML):Null<TEntityTime> {
		final utc = xml.elements.findElement("utc");
		final tzo = xml.elements.findElement("tzo");
		if (utc == null || tzo == null || utc.text == null || tzo.text == null)
			return null;
		final utc:String = StringTools.trim(utc.text);
		final tzo:String = StringTools.trim(tzo.text);
		return {
			utc: utc,
			tzo: tzo,
			date: DelayedDelivery.parseStamp(utc),
			offset: parseOffset(tzo)
		};
	}

	/**
		Creates a `<time/>` element with the given `date` and the local time zone offset.
	**/
	@:noUsing
	public static function createTime(date:Date):XML {
		return Payload.create(XMLNS, "time")
			.append(XML.create("tzo", formatOffset(-date.getTimezoneOffset())))
			.append(XML.create("utc", DelayedDelivery.formatStamp(date)));
	}

	/**
		Answer time requests of other entities with the current time.

		The answer reveals the local time zone of the user.
		An entity answering requests MUST advertise the `XMLNS` feature in its service discovery responses.
	**/
	@:noUsing
	public static function handleRequests(stream:Stream) {
		stream.features.set(XMLNS, (iq, respond) -> {
			respond((iq.type == Get) ? Response.success(createTime(Date.now())) : Response.failure(cancel, bad_request));
		});
	}

	/**
		Parses a time zone offset (`Z`, `+hh:mm` or `-hh:mm`) to minutes, returns `null` if invalid.
	**/
	@:noUsing
	public static function parseOffset(tzo:String):Null<Int> {
		if (tzo == "Z")
			return 0;
		final r = ~/^([+-])(\d{2}):(\d{2})$/;
		if (tzo == null || !r.match(tzo))
			return null;
		final minutes = Std.parseInt(r.matched(2)) * 60 + Std.parseInt(r.matched(3));
		return (r.matched(1) == "-") ? -minutes : minutes;
	}

	/**
		Formats a time zone offset in minutes as `+hh:mm`/`-hh:mm`, or `Z` for `0`.
	**/
	@:noUsing
	public static function formatOffset(minutes:Int):String {
		if (minutes == 0)
			return "Z";
		final abs = Std.int(Math.abs(minutes));
		function pad(v:Int)
			return StringTools.lpad(Std.string(v), "0", 2);
		return (minutes < 0 ? "-" : "+") + pad(Std.int(abs / 60)) + ":" + pad(abs % 60);
	}
}
