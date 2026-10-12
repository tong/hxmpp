package xmpp.client;

import xmpp.IQ;

/**
	Registration information returned by a host.
**/
typedef RegistrationFields = {
	/** `true` if the entity is already registered **/
	var registered:Bool;

	var ?instructions:String;

	/** Names of the requested fields, e.g. `username`, `password`, `email` **/
	var fields:Array<String>;

	/** Values of fields (e.g. the current registration if `registered`) **/
	var values:Map<String, String>;

	/** Data form to submit instead of the fields, if provided **/
	var ?form:DataForm;
}

/**
	Register accounts with servers and services (in-band registration).

	- To create an account on a server, open a stream, secure it with TLS, check `isOffered` on the stream features,
	  then request and submit the registration fields before authenticating.
	- Registration and password changes transfer the password itself: only use them on a TLS secured stream.
	- If the host provides a data form, submit the form (`submitForm`) instead of the fields.
	- Hosts may answer with an error containing a data form requesting more information
	  (e.g. on password changes or cancellation), available as `error.payload`.
	- After a successful `unregister` the server closes the stream with a `not-authorized` stream error.

	All requests go to the own server if `jid` is `null`, or to the service `jid` (e.g. a gateway).

	[XEP-0077: In-Band Registration](https://xmpp.org/extensions/xep-0077.html)
**/
@xep(77)
class Account {
	public static inline var XMLNS = "jabber:iq:register";

	/** Stream feature announcing in-band registration **/
	public static inline var XMLNS_FEATURE = "http://jabber.org/features/iq-register";

	/**
		Returns `true` if the stream features announce in-band registration.
	**/
	@:noUsing
	public static function isOffered(features:Null<XML>):Bool
		return features != null && features.elements.first(e -> e.name == "register" && e.is(XMLNS_FEATURE)) != null;

	/**
		Request the registration fields. Use `parseFields` to read the result.
	**/
	public static inline function requestRegistrationFields(stream:Stream, ?jid:String, handler:Response<XML>->Void):IQ
		return stream.get(XMLNS, jid, handler);

	/**
		Parses the registration fields of a `requestRegistrationFields` result.
	**/
	@:noUsing
	public static function parseFields(payload:XML):RegistrationFields {
		final r:RegistrationFields = {registered: false, fields: [], values: []};
		for (e in payload.elements) {
			switch e.name {
				case "registered":
					r.registered = true;
				case "instructions":
					final t:String = e.text;
					if (t != null)
						r.instructions = StringTools.trim(t);
				case "x" if (e.is(DataForm.XMLNS)):
					r.form = DataForm.fromXML(e);
				case name if (e.ns == null):
					r.fields.push(name);
					final t:String = e.text;
					if (t != null && t.length > 0)
						r.values.set(name, t);
				case _:
			}
		}
		return r;
	}

	/**
		Register with the given field values (e.g. `["username" => "juliet", "password" => "R0m30"]`).
	**/
	public static function register(stream:Stream, fields:Map<String, String>, ?jid:String, handler:Response<XML>->Void):IQ {
		final x = Payload.create(XMLNS);
		final names = [for (k in fields.keys()) k];
		names.sort((a, b) -> a < b ? -1 : a > b ? 1 : 0);
		for (name in names)
			x.append(XML.create(name, fields.get(name)));
		return stream.set(x, jid, handler);
	}

	/**
		Submit a data form, e.g. a registration, password change or cancellation form completed with `DataForm.createSubmit`.
	**/
	public static function submitForm(stream:Stream, form:DataForm, ?jid:String, handler:Response<XML>->Void):IQ
		return stream.set(Payload.create(XMLNS).append(form.toXML()), jid, handler);

	/**
		Cancel the registration.
	**/
	public static function unregister(stream:Stream, ?jid:String, handler:Response<XML>->Void):IQ
		return stream.set(Payload.create(XMLNS).append(XML.create("remove")), jid, handler);

	/**
		Change the password of the account `username`.

		An empty password is refused (`not-acceptable`) without sending a request; returns `null` then.
	**/
	public static function changePassword(stream:Stream, username:String, password:String, ?jid:String, handler:Response<XML>->Void):Null<IQ> {
		if (password == null || password.length == 0) {
			handler(Response.failure(modify, not_acceptable, "empty password"));
			return null;
		}
		return stream.set(Payload.create(XMLNS).append(XML.create("username", username)).append(XML.create("password", password)), jid, handler);
	}
}
