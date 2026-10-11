package xmpp.client;

import xmpp.IQ;

typedef Registration = {
	username:String,
	password:String,
	?email:String
}

/**
	In-band registration with xmpp servers.

	[XEP-0077: In-Band Registration](https://xmpp.org/extensions/xep-0077.html)
**/
@xep(77)
class Account {
	public static inline var XMLNS = "jabber:iq:register";

	/**
	**/
	public static inline function requestRegistrationFields(stream:Stream, handler:Response<XML>->Void):IQ
		return stream.get(XMLNS, handler);

	/**
	**/
	public static function register<T:Registration>(stream:Stream, registration:T, handler:Response<XML>->Void):IQ {
		var x = Payload.create(XMLNS);
		for (f in Reflect.fields(registration))
			x.append(XML.create(f, cast(Reflect.field(registration, f), String)));
		return stream.set(x, handler);
	}

	// public static inline function submitRegistratonFrom(stream: Stream, form: DataForm, handler: Response<XML>->Void) : IQ
	//    return stream.get(Payload.create(XMLNS).append(form), handler);

	/**
		Cancel a registration with a host.
	**/
	public static function unregister(stream:Stream, handler:Response<XML>->Void):IQ
		return stream.set(Payload.create(XMLNS).append(XML.create("remove")), handler);

	/**
	**/
	public static function changePassword(stream:Stream, node:String, password:String, handler:Response<XML>->Void):IQ
		return stream.set(Payload.create(XMLNS).append(XML.create("username", node)).append(XML.create("password", password)), handler);
}
