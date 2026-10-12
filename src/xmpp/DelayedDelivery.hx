package xmpp;

typedef TDelay = {
	/**
		The Jabber ID of the entity that originally sent the XML stanza or that delayed the delivery of the stanza (e.g., the address of a multi-user chat room).
	**/
	?from:String,

	/**
		The time when the XML stanza was originally sent, as UTC timestamp (e.g. `2002-09-10T23:08:25Z`).
	**/
	stamp:String,

	/**
		The `stamp` as date, `null` if it is not a valid timestamp.
	**/
	date:Null<Date>,

	/**
		Natural-language description of the reason for the delay.
	**/
	?description:String
}

/**
	Communicate the fact that a message or presence stanza has been delivered with a delay.

	Delay information can be forged by the sender and SHOULD NOT be relied on as an accurate delivery path or timing.

	[XEP-0203: Delayed Delivery](https://xmpp.org/extensions/xep-0203.html)
**/
@xep(203)
class DelayedDelivery {
	public static inline var XMLNS = "urn:xmpp:delay";

	/**
		Returns the delay information of the given message or presence, or `null`.
	**/
	public static function delay(stanza:Stanza):Null<TDelay> {
		for (e in stanza.properties) {
			if (e.name != "delay" || !e.is(XMLNS) || !e.has("stamp"))
				continue;
			final stamp = e["stamp"];
			return {
				from: e["from"],
				stamp: stamp,
				date: parseStamp(stamp),
				description: e.text
			};
		}
		return null;
	}

	/**
		Creates a `<delay/>` element, e.g. to add to a stanza being forwarded.
	**/
	@:noUsing
	public static function createDelay(date:Date, ?from:String, ?description:String):XML {
		final xml = XML.create("delay")
			.set("xmlns", XMLNS)
			.set("from", from)
			.set("stamp", formatStamp(date));
		if (description != null)
			xml.text = description;
		return xml;
	}

	/**
		Parses a [XEP-0082](https://xmpp.org/extensions/xep-0082.html) date-time (`CCYY-MM-DDThh:mm:ss[.sss](Z|+hh:mm|-hh:mm)`),
		returns `null` if invalid.

		Note: on hashlink, dates have a resolution of seconds and must not be before 1970.
	**/
	@:noUsing
	public static function parseStamp(stamp:String):Null<Date> {
		final r = ~/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(\.\d+)?(Z|([+-])(\d{2}):(\d{2}))$/;
		if (stamp == null || !r.match(stamp))
			return null;
		function int(i:Int):Int
			return Std.parseInt(r.matched(i));
		final days = daysFromCivil(int(1), int(2), int(3));
		var ms = days * 86400000.0 + int(4) * 3600000.0 + int(5) * 60000.0 + int(6) * 1000.0;
		final fraction = r.matched(7);
		if (fraction != null)
			ms += Math.round(Std.parseFloat("0" + fraction) * 1000);
		if (r.matched(8) != "Z") {
			final offset = int(10) * 3600000.0 + int(11) * 60000.0;
			ms += (r.matched(9) == "+") ? -offset : offset;
		}
		return Date.fromTime(ms);
	}

	/**
		Formats `date` as UTC [XEP-0082](https://xmpp.org/extensions/xep-0082.html) date-time, e.g. `2002-09-10T23:08:25Z`.
	**/
	@:noUsing
	public static function formatStamp(date:Date):String {
		function pad(v:Int, n = 2)
			return StringTools.lpad(Std.string(v), "0", n);
		return '${pad(date.getUTCFullYear(), 4)}-${pad(date.getUTCMonth() + 1)}-${pad(date.getUTCDate())}'
			+ 'T${pad(date.getUTCHours())}:${pad(date.getUTCMinutes())}:${pad(date.getUTCSeconds())}Z';
	}

	/** Days since 1970-01-01 of the given date in the proleptic Gregorian calendar **/
	static function daysFromCivil(y:Int, m:Int, d:Int):Float {
		if (m <= 2)
			y--;
		final era = Math.floor(y / 400);
		final yoe = y - era * 400;
		final doy = Std.int((153 * (m + (m > 2 ? -3 : 9)) + 2) / 5) + d - 1;
		final doe = yoe * 365 + Std.int(yoe / 4) - Std.int(yoe / 100) + doy;
		return era * 146097.0 + doe - 719468;
	}
}
