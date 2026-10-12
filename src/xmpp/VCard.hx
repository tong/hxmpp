package xmpp;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import xmpp.IQ;

typedef VCardPhoto = {
	/** MIME type, e.g. `image/png` **/
	var ?type:String;

	/** The image data **/
	var ?data:Bytes;

	/** URL of the image (instead of `data`) **/
	var ?url:String;
}

typedef VCardTel = {
	var number:String;

	/** Types, e.g. `HOME`, `WORK`, `VOICE`, `FAX`, `CELL` **/
	var ?types:Array<String>;
}

typedef VCardEmail = {
	var userid:String;

	/** Types, e.g. `HOME`, `WORK`, `INTERNET`, `PREF` **/
	var ?types:Array<String>;
}

/**
	Common vCard fields. Other fields (e.g. addresses) are not represented, use the raw XML for them.
**/
typedef VCardData = {
	/** Formatted (full) name **/
	var ?fn:String;

	var ?family:String;
	var ?given:String;
	var ?middle:String;
	var ?nickname:String;
	var ?photo:VCardPhoto;

	/** Birthday, e.g. `1966-08-06` **/
	var ?bday:String;

	var ?url:String;
	var ?orgName:String;
	var ?orgUnit:String;
	var ?title:String;
	var ?role:String;
	var ?desc:String;
	var ?jabberId:String;
	var ?tel:Array<VCardTel>;
	var ?email:Array<VCardEmail>;
}

/**
	Retrieve and publish vCards (user profiles, including the avatar photo).

	- Without `jid`, `getVCard` retrieves the own vCard; `setVCard` always sets the own vCard.
	- If no vCard exists, servers answer with an error or an empty vCard, see `isEmpty`.
	- Element names of vCards are in all caps; use `create` to build a valid vCard.
	- This protocol is historical: vCard4 over PEP ([XEP-0292](https://xmpp.org/extensions/xep-0292.html))
	  and PEP avatars ([XEP-0084](https://xmpp.org/extensions/xep-0084.html)) are the modern replacements.

	[XEP-0054: vcard-temp](https://xmpp.org/extensions/xep-0054.html)
**/
@xep(54)
class VCard {
	public static inline var XMLNS = "vcard-temp";

	/**
		Retrieve the vCard of `jid`, or the own vCard if `null`. Use `parse` to read the result.
	**/
	public static inline function getVCard(stream:Stream, ?jid:String, handler:Response<XML>->Void):IQ
		return stream.get(Payload.create(XMLNS, "vCard"), jid, handler);

	/**
		Publish the own vCard, a `<vCard/>` element (see `create`).
	**/
	public static function setVCard(stream:Stream, vcard:XML, handler:Response<XML>->Void):IQ {
		final payload:XML = if (vcard.name == "vCard") {
			vcard.set("xmlns", XMLNS);
		} else {
			// a single field
			Payload.create(XMLNS, "vCard").append(vcard);
		}
		return stream.set(payload, handler);
	}

	/**
		Returns `true` if the response of `getVCard` means that no vCard exists:
		an `item-not-found` or `service-unavailable` error, or an empty vCard.
	**/
	@:noUsing
	public static function isEmpty(response:Response<XML>):Bool {
		return switch (response : Response.EResponse<XML>) {
			case Result(payload): payload == null || payload.elements.length == 0;
			case Error(e): e.condition == item_not_found || e.condition == service_unavailable;
		}
	}

	/**
		Parses a `<vCard/>` element.
	**/
	@:noUsing
	public static function parse(xml:XML):VCardData {
		final v:VCardData = {};
		function text(e:Null<XML>):Null<String> {
			if (e == null)
				return null;
			final t:String = e.text;
			return (t == null) ? null : StringTools.trim(t);
		}
		for (e in xml.elements) {
			switch e.name {
				case "FN": v.fn = text(e);
				case "N":
					v.family = text(e.elements.findElement("FAMILY"));
					v.given = text(e.elements.findElement("GIVEN"));
					v.middle = text(e.elements.findElement("MIDDLE"));
				case "NICKNAME": v.nickname = text(e);
				case "BDAY": v.bday = text(e);
				case "URL": v.url = text(e);
				case "ORG":
					v.orgName = text(e.elements.findElement("ORGNAME"));
					v.orgUnit = text(e.elements.findElement("ORGUNIT"));
				case "TITLE": v.title = text(e);
				case "ROLE": v.role = text(e);
				case "DESC": v.desc = text(e);
				case "JABBERID": v.jabberId = text(e);
				case "PHOTO":
					final photo:VCardPhoto = {};
					photo.type = text(e.elements.findElement("TYPE"));
					photo.url = text(e.elements.findElement("EXTVAL"));
					final binval = text(e.elements.findElement("BINVAL"));
					if (binval != null && binval.length > 0)
						photo.data = try Base64.decode(~/\s+/g.replace(binval, "")) catch (_) null;
					v.photo = photo;
				case "TEL":
					final number = text(e.elements.findElement("NUMBER"));
					if (number != null && number.length > 0) {
						if (v.tel == null)
							v.tel = [];
						v.tel.push({number: number, types: [for (t in e.elements) if (t.name != "NUMBER") t.name]});
					}
				case "EMAIL":
					final userid = text(e.elements.findElement("USERID"));
					if (userid != null && userid.length > 0) {
						if (v.email == null)
							v.email = [];
						v.email.push({userid: userid, types: [for (t in e.elements) if (t.name != "USERID") t.name]});
					}
			}
		}
		return v;
	}

	/**
		Creates a `<vCard/>` element.
	**/
	@:noUsing
	public static function create(v:VCardData):XML {
		final xml = XML.create("vCard").set("xmlns", XMLNS);
		function add(parent:XML, name:String, value:Null<String>)
			if (value != null)
				parent.append(XML.create(name, value));
		add(xml, "FN", v.fn);
		if (v.family != null || v.given != null || v.middle != null) {
			final n = XML.create("N");
			add(n, "FAMILY", v.family);
			add(n, "GIVEN", v.given);
			add(n, "MIDDLE", v.middle);
			xml.append(n);
		}
		add(xml, "NICKNAME", v.nickname);
		if (v.photo != null) {
			final photo = XML.create("PHOTO");
			if (v.photo.data != null) {
				add(photo, "TYPE", v.photo.type);
				photo.append(XML.create("BINVAL", Base64.encode(v.photo.data)));
			} else
				add(photo, "EXTVAL", v.photo.url);
			xml.append(photo);
		}
		add(xml, "BDAY", v.bday);
		add(xml, "URL", v.url);
		if (v.orgName != null || v.orgUnit != null) {
			final org = XML.create("ORG");
			add(org, "ORGNAME", v.orgName);
			add(org, "ORGUNIT", v.orgUnit);
			xml.append(org);
		}
		add(xml, "TITLE", v.title);
		add(xml, "ROLE", v.role);
		if (v.tel != null)
			for (t in v.tel) {
				final tel = XML.create("TEL");
				if (t.types != null)
					for (type in t.types)
						tel.append(XML.create(type.toUpperCase()));
				tel.append(XML.create("NUMBER", t.number));
				xml.append(tel);
			}
		if (v.email != null)
			for (m in v.email) {
				final email = XML.create("EMAIL");
				if (m.types != null)
					for (type in m.types)
						email.append(XML.create(type.toUpperCase()));
				email.append(XML.create("USERID", m.userid));
				xml.append(email);
			}
		add(xml, "JABBERID", v.jabberId);
		add(xml, "DESC", v.desc);
		return xml;
	}
}
