package xmpp;

/**
	A runtime value that describes the absence of a value.
**/
enum Nil { nil; }

enum EResponse<T:xmpp.IQ.Payload> {

    /** Contains the success value **/
	Result(payload:T);

    /** Contains the error value **/
	Error(error:xmpp.Stanza.Error);
}

/**
    A query response representing either success (`Result`) or failure (`Error`).
**/
abstract Response<T:xmpp.IQ.Payload>(EResponse<T>) from EResponse<T> to EResponse<T> {

    /** The payload **/
    public var payload(get,never) : T;
    inline function get_payload() : T return switch this {
        case Result(r): r;
        case Error(_): null;
    }

    /** The error **/
    public var error(get,never) : xmpp.Stanza.Error;
    inline function get_error() : xmpp.Stanza.Error return switch this {
        case Result(_): null;
        case Error(e): e;
    }


    /** The payload namespace **/
    public var xmlns(get,never) : String;
    inline function get_xmlns() : String return switch this {
        case Result(r): r.get('xmlns');
        case Error(_): null;
    }

    inline function new(r:Response<T>) this = r;

    /** Returns `true` if payload namespace matches **/
    public inline function is(xmlns:String):Bool
        return get_xmlns() == xmlns;

    @:to public inline function ok():Bool
        return switch this {
		    case Result(_): true;
		    case Error(_): false;
    	}
	
    public inline function sure():Null<T>
		return switch this {
			case Result(r): r;
			case Error(e): throw e;
		}

    @:to public inline function toXML():XML
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
}

