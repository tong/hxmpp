package xmpp;

import xmpp.DataForm;
import xmpp.Response;
import xmpp.ResultSet;

/**
	What to query from a message archive.
**/
typedef MamQuery = {
	/** Only messages exchanged with this jid (bare: all clients of the contact) **/
	var ?with:String;

	/** Only messages archived at or after this time **/
	var ?start:Date;

	/** Only messages archived at or before this time **/
	var ?end:Date;

	/**
		The page to return: `max` messages, `after`/`before` an archive id (`before: ""`: the last page, the most
		recent messages). Without, the server returns its default page from the oldest messages.
	**/
	var ?page:ResultSetRequest;
}

/**
	A message of an archive.
**/
typedef MamItem = {
	/** Id of the message in the archive (`stanza-id`), e.g. to page **/
	var id:String;

	var message:Message;

	/** When the message was archived (sent), `null` if the archive gave no time **/
	var ?date:Date;
}

/**
	A page of an archive query.
**/
typedef MamResult = {
	/** The messages, oldest first **/
	var items:Array<MamItem>;

	/** `true` if the page reaches the end of the query (the last page in the direction of paging) **/
	var complete:Bool;

	/** The first and last archive id of the page, and the number of messages of the query if the server counts **/
	var page:ResultSetPage;
}

/**
	The response to an archive query.
**/
enum MamResponse {
	/** The page of messages **/
	Page(result:MamResult);

	/** The error, e.g. `feature-not-implemented`, `item-not-found` for an unknown archive id **/
	Failed(error:xmpp.Stanza.Error);
}

/**
	Query archives of messages kept by the server: the own messages (one-to-one chats), or the messages of rooms.

	Results arrive as messages before the response of the query: pass all received messages to `handleMessage`,
	which consumes those of running queries.

		final mam = new Mam(stream);
		stream.onMessage = m -> if (!mam.handleMessage(m)) receive(m);
		// the last 20 messages with juliet
		mam.query({with: "juliet@capulet.lit", page: {max: 20, before: ""}}, res -> switch res {
			case Page(r): for (item in r.items) trace(item.date, item.message.body);
			case Failed(e): trace(e.condition);
		});

	Support is advertised by the own bare jid (service discovery: `Mam.XMLNS`), and by rooms with archives.

	[XEP-0313: Message Archive Management](https://xmpp.org/extensions/xep-0313.html)
**/
@xep(313)
class Mam {
	public static inline var XMLNS = "urn:xmpp:mam:2";

	static inline var XMLNS_FORWARD = "urn:xmpp:forward:0";

	public final stream:Stream;

	/** The running queries by query id: the archive queried and the results received so far **/
	final queries = new Map<String, {archive:Null<String>, items:Array<MamItem>}>();

	public function new(stream:Stream)
		this.stream = stream;

	/**
		Queries the archive of `archive` (a room, default the own account) with `query`; `handler` gets the page
		once complete, or the error.
	**/
	public function query(query:MamQuery, ?archive:String, handler:MamResponse->Void):IQ {
		final id = xmpp.Stream.makeRandomId();
		queries.set(id, {archive: (archive != null) ? Jid.parseBare(archive) : null, items: []});
		return stream.set(createQuery(id, query), archive, (res:Response<XML>) -> {
			final items = queries.get(id)?.items ?? [];
			queries.remove(id);
			handler(switch res {
				case Result(fin): Page({
						items: items,
						complete: fin != null && fin.get("complete") == "true",
						page: ResultSet.get(fin) ?? {}
					});
				case Error(e): Failed(e);
			});
		});
	}

	/**
		Handles a received message: returns `true` if it is a result of a running query (it should not be processed
		further), `false` for other messages.
		Results from other entities than the archive queried are ignored (consumed, as they may be forged).
	**/
	public function handleMessage(message:Message):Bool {
		for (e in message.properties) {
			if (e.name != "result" || !e.is(XMLNS))
				continue;
			final query = queries.get(e.get("queryid"));
			if (query == null)
				return false;
			if (message.from == null || isArchive(message.from, query.archive)) {
				final item = parseResult(e);
				if (item != null)
					query.items.push(item);
			}
			return true;
		}
		return false;
	}

	function isArchive(from:String, archive:Null<String>):Bool {
		final own = (stream.jid != null) ? Jid.parseBare(stream.jid) : null;
		return Jid.normalize(from) == Jid.normalize(archive ?? own ?? "");
	}

	/**
		Creates the `<query/>` of a query with id `queryId`.
	**/
	@:noUsing
	public static function createQuery(queryId:String, query:MamQuery):XML {
		final xml = XML.create("query").set("xmlns", XMLNS).set("queryid", queryId);
		final fields = new Array<Field>();
		if (query.with != null)
			fields.push({variable: "with", values: [query.with]});
		if (query.start != null)
			fields.push({variable: "start", values: [DelayedDelivery.formatStamp(query.start)]});
		if (query.end != null)
			fields.push({variable: "end", values: [DelayedDelivery.formatStamp(query.end)]});
		if (fields.length > 0) {
			fields.unshift({variable: "FORM_TYPE", type: hidden, values: [XMLNS]});
			xml.append(new DataForm(submit, null, null, fields));
		}
		if (query.page != null)
			xml.append(ResultSet.create(query.page));
		return xml;
	}

	/**
		Parses a `<result/>` of a query: the archived message with its archive id and time, `null` if it is invalid.
	**/
	@:noUsing
	public static function parseResult(result:XML):Null<MamItem> {
		final id = result.get("id");
		final forwarded = result.elements.first(e -> e.name == "forwarded" && e.is(XMLNS_FORWARD));
		final message = forwarded?.elements.findElement("message");
		if (id == null || message == null)
			return null;
		final delay = forwarded.elements.first(e -> e.name == "delay" && e.is(DelayedDelivery.XMLNS));
		final item:MamItem = {id: id, message: Message.fromXML(message)};
		final date = (delay != null) ? DelayedDelivery.parseStamp(delay.get("stamp")) : null;
		if (date != null)
			item.date = date;
		return item;
	}
}
