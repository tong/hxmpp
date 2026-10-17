package xmpp;

import xmpp.IQ;
import xmpp.JingleFileTransfer;

/** A listing of shared files: the directories and files of a directory (only directories at the root) **/
typedef FileListing = {
	/** Names of the directories (without path) **/
	var directories:Array<String>;

	/** The files: `name` (without path), optionally size, date, hashes **/
	var files:Array<JingleFile>;
}

/**
	Share files: other entities list the shared directories and files of a client (`list`) and request a file with
	Jingle (`JingleFileTransfer.requestFile`, its `name` the path, e.g. `pics/cat.png`). The sharing client answers
	listings (`handleRequests`) and file requests (`JingleFileTransfer.getFileRequest`, `answerFileRequest`).

		FileSharing.list(stream, "juliet@capulet.lit/balcony", null, res -> ...);   // the root: directories
		FileSharing.list(stream, "juliet@capulet.lit/balcony", "pics", res -> ...); // a directory
		FileSharing.handleRequests(stream, (from, node) -> listing(node), from -> isContact(from));

	Rules:
	- Paths are relative to the shared root, separated by `/`. The root lists directories only.
	- Requests of paths outside the shared directories (`..`, links) must be refused: share only what is listed.
	- The listing may differ by requester (e.g. directories only for some contacts).
	- Files should have hashes (the requester verifies the data); empty directories are not listed.

	The protocol is deferred: few clients implement it.

	[XEP-0329: File Information Sharing](https://xmpp.org/extensions/xep-0329.html)
**/
@xep(329)
class FileSharing {
	public static inline var XMLNS = "urn:xmpp:fis:0";

	/** The file transfer namespace of the files of older versions (accepted when parsing) **/
	static inline var XMLNS_FILE_4 = "urn:xmpp:jingle:apps:file-transfer:4";

	/**
		Request the listing of `node` (a path, the root if `null`) of `jid` (a full jid), see `parseListing`.
	**/
	@:noUsing
	public static inline function list(stream:Stream, jid:String, ?node:String, handler:Response<XML>->Void):IQ
		return stream.get(createQuery(node), jid, handler);

	/** A `<query/>` for the listing of `node` **/
	@:noUsing
	public static function createQuery(?node:String):XML {
		final q = XML.create("query").set("xmlns", XMLNS);
		if (node != null && node.length > 0)
			q.set("node", node);
		return q;
	}

	/** The listing of `node`: the answer to a query **/
	@:noUsing
	public static function createListing(?node:String, listing:FileListing):XML {
		final q = createQuery(node);
		for (f in listing.files)
			q.append(JingleFileTransfer.createFile(f).set("xmlns", JingleFileTransfer.XMLNS));
		for (d in listing.directories)
			q.append(XML.create("directory").set("name", d));
		return q;
	}

	/** The listing of an answer, `null` if it is none **/
	@:noUsing
	public static function parseListing(payload:Null<XML>):Null<FileListing> {
		if (payload == null || payload.name != "query" || !payload.is(XMLNS))
			return null;
		final listing:FileListing = {directories: [], files: []};
		for (e in payload.elements)
			switch e.name {
				case "directory" if (e.has("name")):
					listing.directories.push(e.get("name"));
				case "file" if (e.is(JingleFileTransfer.XMLNS) || e.is(XMLNS_FILE_4)):
					final f = JingleFileTransfer.parseFile(e);
					if (f.name != null)
						listing.files.push(f);
				case _:
			}
		return listing;
	}

	/**
		Answers listing requests: `handler` gets the requester (full jid) and the node (the path, `null` for the root)
		and returns the listing, `null` if there is no such directory (`item-not-found`). Requests of entities
		`allowed` refuses are answered with `forbidden`.
	**/
	@:noUsing
	public static function handleRequests(stream:Stream, handler:(from:String, node:Null<String>) -> Null<FileListing>, ?allowed:String->Bool) {
		stream.features.set(XMLNS, (iq, respond) -> {
			if (iq.type != Get) {
				respond(Response.failure(cancel, bad_request));
				return;
			}
			if (iq.from == null || (allowed != null && !allowed(iq.from))) {
				respond(Response.failure(auth, forbidden));
				return;
			}
			final node = iq.payload.get("node");
			final listing = try handler(iq.from, (node == null || node.length == 0) ? null : node) catch (e) null;
			respond((listing == null) ? Response.failure(cancel, item_not_found) : Response.success(createListing(node, listing)));
		});
	}
}
