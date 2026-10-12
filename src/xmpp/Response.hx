package xmpp;

enum EResponse<T:xmpp.IQ.Payload> {
	/** Success, with the payload of the result (`null` for an empty result) **/
	Result(payload:T);

	/** Failure, with the stanza error **/
	Error(error:xmpp.Stanza.Error);
}

/**
	A query response representing either success (`Result`) or failure (`Error`).

	Converts implicitly to `Bool` (`true` on success):

		stream.get(XMLNS, res -> if (res) trace(res.payload) else trace(res.error.condition));

	Note: in modules importing `xmpp.IQ` the names `Result` and `Error` refer to `IQType` values,
	and importing `xmpp.Stanza` makes `Error` refer to `xmpp.Stanza.Error`;
	use `Response.success()` and `Response.failure()` (or `EResponse.Result`/`EResponse.Error`) there to create responses.
**/
abstract Response<T:xmpp.IQ.Payload>(EResponse<T>) from EResponse<T> to EResponse<T> {
	/** The payload, `null` on failure or for an empty result **/
	public var payload(get, never):Null<T>;

	inline function get_payload():Null<T>
		return switch this {
			case Result(r): r;
			case Error(_): null;
		}

	/** The error, `null` on success **/
	public var error(get, never):Null<xmpp.Stanza.Error>;

	inline function get_error():Null<xmpp.Stanza.Error>
		return switch this {
			case Result(_): null;
			case Error(e): e;
		}

	/** The payload namespace, `null` on failure or for an empty result **/
	public var xmlns(get, never):Null<String>;

	inline function get_xmlns():Null<String>
		return switch this {
			case Result(r): (r == null) ? null : r.get('xmlns');
			case Error(_): null;
		}

	inline function new(r:Response<T>)
		this = r;

	/**
		Returns `true` if the payload namespace matches `xmlns`.
	**/
	public inline function is(xmlns:String):Bool
		return get_xmlns() == xmlns;

	/**
		Returns `true` on success.
	**/
	@:to public inline function ok():Bool
		return switch this {
			case Result(_): true;
			case Error(_): false;
		}

	/**
		Returns the payload, or throws the `xmpp.Stanza.Error` on failure.
	**/
	public inline function sure():Null<T>
		return switch this {
			case Result(r): r;
			case Error(e): throw e;
		}

	/**
		Returns the payload on success, the `<error/>` element on failure.
	**/
	public inline function toXML():Null<XML>
		return switch this {
			case Result(r): r;
			case Error(e): e.toXML();
		}

	@:to public inline function toOption():haxe.ds.Option<T>
		return switch this {
			case Result(r): haxe.ds.Option.Some(r);
			case Error(_): haxe.ds.Option.None;
		}

	@:from public static inline function fromError<T:xmpp.IQ.Payload>(e:xmpp.Stanza.Error):Response<T>
		return new Response(Error(e));

	/**
		Creates a successful response, with an empty result if `payload` is `null`.
	**/
	public static inline function success<T:xmpp.IQ.Payload>(?payload:T):Response<T>
		return Result(payload);

	/**
		Creates an error response.
	**/
	public static inline function failure<T:xmpp.IQ.Payload>(type:xmpp.Stanza.ErrorType, condition:xmpp.Stanza.ErrorCondition, ?text:String):Response<T>
		return Error(new xmpp.Stanza.Error(type, condition, text));
}
