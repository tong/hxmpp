package xmpp;

import haxe.macro.Expr.Error;
import haxe.crypto.Md5;
import xmpp.IQ;

using StringTools;

private typedef Header = {
	from:String,
	to:String,
	id:String,
	lang:String,
	version:String
}

abstract class Stream {

	public static inline var XMLNS = 'http://etherx.jabber.org/streams';

	public dynamic function onEnd() {}
	public dynamic function onMessage(m:Message) {}
	public dynamic function onPresence(p:Presence) {}
	public dynamic function onIQ(iq:IQ) {}

	public final xmlns:String;
	public final domain:String;
	public final lang:String;

	public var id(default,null):String;
	public var version(default,null) = "1.0";
	public var ready(default,null) = false;
	public var extensions = new Map<String,IQ->Void>();

	public var input:String->Void;
	public var output:String->Void;

	var buffer:StringBuf;
	var queries:Map<String, IQ->Void>;

	function new(xmlns:String, domain:String, ?lang:String) {
		this.xmlns = xmlns;
		this.domain = domain;
		this.lang = lang;
	}

    /**
        Info `get` query
    **/
	public function get<T:IQ.Payload>(payload:IQ.Payload, ?jid:String, handler:(response:Response<T>) -> Void):IQ {
		var iq = new IQ(payload, IQType.Get, createRandomStanzaId(), jid);
        query(iq, (handler==null) ? null : res -> switch res.type {
            case Result: handler(Result(cast res.payload));
            case Error:
                handler(Error(res.error));
            /* if( res.error != null ) {
                    handler( Error( res.error ) );
                } else {
                    if( res.payload != null ) {
                        handler(  new xmpp.Stanza.Error() );
                    }
                    //handler( Error( res.error ) );
            }*/
            default:
        });
		return iq;
	}

    /**
        Info `set` query
    **/
	public function set<T:IQ.Payload>(payload:IQ.Payload, ?jid:String, handler:(response:Response<T>) -> Void):IQ {
		var iq = new IQ(payload, IQType.Set, createRandomStanzaId(), jid);
        if(handler != null) {
            query(iq, res -> switch res.type {
                case Result: handler(Result(cast res.payload));
                case Error:
                    trace(res.error);
                    handler(Error(res.error));
                default:
            });
        } else {
            query(iq, null);
        }
		return iq;
	}

    function query(iq:IQ, callback:(response:IQ) -> Void) {
		if (iq.id == null)
            iq.id = createRandomStanzaId();
        if(callback != null)
            queries.set(iq.id, cast callback);
		send(iq);
	}

    /**
        Send XML stanza
    **/
	public function send(xml:XML) {
		output(xml);
	}

    /**
        Process incoming data
    **/
	public function recv(str:String) {
		if(str == null || str.length == 0)
			return false;
		if(buffer == null) buffer = new StringBuf();
		buffer.add(str);
		if(!str.endsWith('>'))
            return false;
		var received = buffer.toString();
        if(received.endsWith("</stream:stream>")) {
            reset();
            onEnd();
        } else {
            buffer = new StringBuf(); 
            input(received);
        }
        return true;
	}

    /**
        End stream
    **/
	public function end() {
		output('</stream:stream>');
		reset();
	}

	function handleString(str:String) {
		if (!ready)
			return;
		final xml = try Xml.parse(str) catch(e) {
			trace(e);
            if(str.endsWith("</stream:stream>")) {
                onEnd();
                return;
            }
			null;
        }
        if(@:privateAccess cast(xml.elements(),haxe.iterators.ArrayIterator<Dynamic>).array.length == 1) {
           handleXML(xml.firstElement()); 
        } else {
            for(e in xml.elements()) {
                handleXML(e);
            }
        }
	}

	abstract function handleXML(xml:XML) : Void;

	function reset() {
		ready = false;
		buffer = new StringBuf();
		queries = new Map();
	}

	function createRandomStanzaId(length = 8) : String {
		return Std.string(Md5.encode(id + Date.now().getTime() + (Math.random()*1))).substr(0, length);
	}

	static function createHeader(xmlns:String, to:String, ?version:String, ?lang:String):String {
		final xml = XML.create('stream:stream')
			.set('xmlns', xmlns)
			.set('xmlns:stream', xmpp.Stream.XMLNS)
			.set('to', to);
		if (version != null) xml.set('version', version);
		if (lang != null) xml.set('xml:lang', lang);
		var str = xml.toString();
		str = str.substr(0, str.lastIndexOf('/')) + '>';
		return str;
		// return '<?xml version="1.0" encoding="UTF-8"?>'+str;
	}

	static function readHeader(str:String):Header {
		final r = ~/^(<\?xml) (.)+\?>/;
		if (r.match(str)) str = r.matchedRight();
		// TODO handle stream:error
		// var i = str.lastIndexOf( "/>" );
		if(!str.endsWith('/>')) {
			final i = str.indexOf(">");
			if (i == -1)
				throw 'invalid stream header'; // TODO:
			str = str.substr(0, i) + '/>';
		}
		final xml = XML.parse(str).firstElement;
		return {
			id: xml.get("id"),
			from: xml.get("from"),
			to: xml.get("to"),
			version: xml.get("version"),
			lang: xml.get("lang")
		};
	}

	static function readFeatures(str:String):XML {
		var i = str.indexOf("<stream:features");
		if (i == -1)
			return null;
        str = str.substr(i);
		i = str.indexOf("</stream:stream>");
		if (i != -1)
			str = str.substr(0, i);
		return XML.parse(str);
	}
}
