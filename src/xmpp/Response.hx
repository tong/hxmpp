package xmpp;

import haxe.ds.Option;

enum TResponse<T:IQ.Payload> {

    /** Contains the success value **/
	Result(payload:T);

    /** Contains the error value **/
	Error(error:xmpp.Stanza.Error);
}

/**
    A query response representing either success (Result) or failure (Error).
**/
abstract Response<T:IQ.Payload>(TResponse<T>) from TResponse<T> to TResponse<T> {

    /** The payload **/
    public var payload(get,never) : T;
    inline function get_payload() : T return switch this {
        case Result(pl): pl;
        case Error(e): null;
    }

    /** The payload namespace **/
    public var xmlns(get,never) : String;
    inline function get_xmlns() : String return switch this {
        case Result(pl): pl.get('xmlns');
        case Error(e): null;
    }

    inline function new(r:Response<T>) this = r;

    /** Returns `true` if payload namespace matches **/
    public inline function is(xmlns:String):Bool
        return get_xmlns() == xmlns;

    @:to public inline function isOk():Bool
        return switch this {
		    case Result(_): true;
		    case Error(_): false;
    	}
	
    public inline function sure():Null<T>
		return switch this {
			case Result(pl): pl;
			case Error(e): throw e;
		}

    @:to public inline function toXML():XML
        return switch this {
		    case Result(pl): pl;
		    case Error(e): e.toXML();
    	}
	
    @:to public inline function toOption():haxe.ds.Option<T>
		return switch this {
			case Result(pl): haxe.ds.Option.Some(pl);
			case Error(e): haxe.ds.Option.None;
		}
}

