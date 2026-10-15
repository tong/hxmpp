package xmpp;

import xmpp.IQ;

using StringTools;

/**
	An external service of the server, e.g. a STUN or TURN server for calls.
**/
typedef ExternalService = {
	/** e.g. `stun`, `turn`, `turns` **/
	var type:String;

	var host:String;
	var ?port:Int;

	/** `udp` or `tcp` **/
	var ?transport:String;

	/** Temporary credentials (e.g. of a TURN server) **/
	var ?username:String;

	var ?password:String;

	/** When the credentials expire, a timestamp **/
	var ?expires:String;

	var ?name:String;
}

/**
	Discover services of the server outside of XMPP, e.g. the STUN and TURN servers to use for calls (with credentials
	for TURN, usually valid for a limited time: request them for each call).

		ExternalServices.request(stream, res -> {
			for (s in ExternalServices.parse(res.payload))
				trace(ExternalServices.uri(s));
		});

	Support is advertised by the server (service discovery: `XMLNS`).

	[XEP-0215: External Service Discovery](https://xmpp.org/extensions/xep-0215.html)
**/
@xep(215)
class ExternalServices {
	public static inline var XMLNS = "urn:xmpp:extdisco:2";

	/**
		Requests the services of the server, all or those of `type` (e.g. `turn`).
	**/
	public static function request(stream:Stream, ?type:String, handler:Response<XML>->Void):IQ
		return stream.get(Payload.create(XMLNS, "services").set("type", type), stream.domain, handler);

	/**
		Parses the services of a response, those without host or type are left out.
	**/
	@:noUsing
	public static function parse(payload:Null<XML>):Array<ExternalService> {
		if (payload == null)
			return [];
		final list = new Array<ExternalService>();
		for (e in payload.elements.named("service")) {
			if (!e.has("host") || !e.has("type"))
				continue;
			final s:ExternalService = {type: e.get("type"), host: e.get("host")};
			final port = Std.parseInt(e.get("port"));
			if (port != null)
				s.port = port;
			for (k in ["transport", "username", "password", "expires", "name"])
				if (e.has(k))
					Reflect.setField(s, k, e.get(k));
			list.push(s);
		}
		return list;
	}

	/**
		The URI of a STUN or TURN service, e.g. `stun://stun.example.org:3478` or
		`turn://user:password@turn.example.org:3478?transport=udp` (credentials percent-encoded), `null` for other types.
	**/
	@:noUsing
	public static function uri(service:ExternalService):Null<String> {
		final type = service.type.toLowerCase();
		if (type != "stun" && type != "turn" && type != "turns")
			return null;
		final host = service.host.contains(":") && !service.host.startsWith("[") ? '[${service.host}]' : service.host;
		final address = host + (service.port != null ? ':${service.port}' : '');
		if (type == "stun")
			return 'stun://$address';
		final user = (service.username != null) ? StringTools.urlEncode(service.username) + ":" + StringTools.urlEncode(service.password ?? "") + "@" : "";
		return '$type://$user$address' + (service.transport != null ? '?transport=${service.transport}' : '');
	}
}
