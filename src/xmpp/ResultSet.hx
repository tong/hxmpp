package xmpp;

/**
	Request for a page of a result set.
**/
typedef ResultSetRequest = {
	/** Maximum number of items to return; `0` requests only the item count **/
	var ?max:Int;

	/** Return the items after the item with this id **/
	var ?after:String;

	/** Return the items before the item with this id; an empty string requests the last page **/
	var ?before:String;

	/** Return the items starting at this index **/
	var ?index:Int;
}

/**
	A page of a result set, as returned by the responding entity.
**/
typedef ResultSetPage = {
	/** Id of the first item of the page, `null` if the page is empty **/
	var ?first:String;

	/** Index of the first item in the full result set **/
	var ?firstIndex:Int;

	/** Id of the last item of the page, `null` if the page is empty **/
	var ?last:String;

	/** Number of items in the full result set **/
	var ?count:Int;
}

/**
	Extension that enables an entity to page through and otherwise manage the receipt of large result sets.

	The `<set/>` element is included in the payload of other requests (e.g. service discovery items,
	message archives or pubsub items) and their results:

		final query = Payload.create(ServiceDiscovery.XMLNS_ITEMS).append(ResultSet.create({max: 10}));
		stream.get(query, jid, res -> {
			final page = ResultSet.get(res.payload);
			// request the next page with ResultSet.nextPage(page, 10)
		});

	[XEP-0059: Result Set Management](https://xmpp.org/extensions/xep-0059.html)
**/
@xep(59)
class ResultSet {
	public static inline var XMLNS = "http://jabber.org/protocol/rsm";

	/**
		Creates a `<set/>` element requesting a page.
	**/
	@:noUsing
	public static function create(request:ResultSetRequest):XML {
		final xml = XML.create("set").set("xmlns", XMLNS);
		if (request.max != null)
			xml.append(XML.create("max", Std.string(request.max)));
		if (request.after != null)
			xml.append(XML.create("after", request.after));
		if (request.before != null)
			xml.append(request.before.length == 0 ? XML.create("before") : XML.create("before", request.before));
		if (request.index != null)
			xml.append(XML.create("index", Std.string(request.index)));
		return xml;
	}

	/**
		Parses a `<set/>` element of a result.
	**/
	@:noUsing
	public static function parse(xml:XML):ResultSetPage {
		final page:ResultSetPage = {};
		for (e in xml.elements) {
			final text:String = e.text;
			switch e.name {
				case "first":
					page.first = text;
					if (e.has("index"))
						page.firstIndex = Std.parseInt(e.get("index"));
				case "last":
					page.last = text;
				case "count":
					page.count = Std.parseInt(text);
			}
		}
		return page;
	}

	/**
		Returns the result set page contained in `payload` (e.g. a result query), or `null` if there is none.
	**/
	@:noUsing
	public static function get(payload:Null<XML>):Null<ResultSetPage> {
		if (payload == null)
			return null;
		final set = payload.elements.first(e -> e.name == "set" && e.is(XMLNS));
		return (set == null) ? null : parse(set);
	}

	/**
		Creates the request for the page after `page`, or `null` if `page` is empty.
	**/
	@:noUsing
	public static function nextPage(page:ResultSetPage, max:Int):Null<XML>
		return (page.last == null) ? null : create({max: max, after: page.last});

	/**
		Creates the request for the page before `page`, or `null` if `page` is empty.
	**/
	@:noUsing
	public static function previousPage(page:ResultSetPage, max:Int):Null<XML>
		return (page.first == null) ? null : create({max: max, before: page.first});

	/**
		Creates the request for the last page.
	**/
	@:noUsing
	public static inline function lastPage(max:Int):XML
		return create({max: max, before: ""});
}
