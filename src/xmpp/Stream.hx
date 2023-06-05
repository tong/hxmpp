package xmpp;

import haxe.crypto.Md5;
import xmpp.IQ;
import xmpp.Response;

using StringTools;

private typedef Header = {
	from: String,
	to: String,
	id: String,
	lang: String,
	version: String
}

abstract class Stream {

	public static inline var XMLNS = 'http://etherx.jabber.org/streams';

    /** Handle message stanzas **/
	public dynamic function onMessage(m:Message) {}

    /** Handle presence stanzas **/
	public dynamic function onPresence(p:Presence) {}

    /** Handle iq (get,set) stanzas **/
	public dynamic function onIQ(iq:IQ, res:Null<Response<XML>>->Void) {}

    /** Handle raw xml **/
	public dynamic function onRaw(xml:XML):Bool return false;

    /** Stream end handler **/
	public dynamic function onEnd() {}

	public final xmlns:String;
	public final domain:String;
	public final lang:String;

	public var id(default,null):String;
	public var version(default,null) = "1.0";
	public var ready(default,null) = false;

	public var input:String->Void;
	public var output:String->Void;
	
    public var features = new Map<String,IQ->(?Null<Response<XML>>->Void)->Void>();
	public var queries(default,null):Map<String,XML->Void>;

	var buf:StringBuf;

	function new(xmlns:String, domain:String, ?lang:String) {
		this.xmlns = xmlns;
		this.domain = domain;
		this.lang = lang;
	}

    /**
        Info `get` query
    **/
	public function get<T:IQ.Payload,R>(payload:IQ.Payload, ?jid:String, ?handler:(response:Response<T>)->Void):IQ {
		final iq = new IQ(payload, IQType.Get, makeRandomId(), jid);
	    if(iq.id == null) iq.id = makeRandomId();
        if(handler != null) {
            queries.set(iq.id, xml -> {
                final iq : IQ = xml;
                switch iq.type {
                case Result: handler(Result(cast iq.payload));
                case Error: handler(Error(iq.error));
                default:
                }

            });
        } else {
            trace("TODO");
            //query(iq, null);
        }
		send(iq);
		return iq;
    }

    /**
        Info `set` query
    **/
    public function set<T:IQ.Payload>(payload:IQ.Payload, ?jid:String, handler:(response:Response<T>)->Void):IQ {
		final iq = new IQ(payload, IQType.Set, makeRandomId(), jid);
        if(handler != null) {
            queries.set(iq.id, xml -> {
                final iq : IQ = xml;
                switch iq.type {
                case Result: handler(Result(cast iq.payload));
                case Error: handler(Error(iq.error));
                default:
                }
            });
        } else {
            trace("TODO");
            //query(iq, null);
        }
        send(iq);
		return iq;
	}

    public function query(stanza:Stanza, handler:(response:XML)->Void) {
		if (stanza.id == null)
            stanza.id = makeRandomId();
        if(handler != null)
            queries.set(stanza.id, handler);
		send(stanza.toXML());
	}

    /**
        Send stanza
    **/
	public function send(xml:XML) : XML {
		output(xml);
        return xml;
	}

    /*
	public function sendStanza<T:xmpp.Stanza>(stanza:T, ?handler:T->Void) : T {
        if(handler != null) {
            if(stanza.id == null) stanza.id = Stream.makeRandomId();
            //queries.set(stanza.id, handler);
        }
        // if(stanza.id != null) {
        //     queries.set(stanza.id, handler);
        // }
        return stanza;
    }
    */

    /**
        Process incoming data
    **/
	public function recv(str:String) : Bool {
		if(str == null || str.length == 0)
			return false;
		if(buf == null) buf = new StringBuf();
		buf.add(str);
		if(!str.endsWith('>'))
            return false;
		var received = buf.toString();
        if(received.endsWith("</stream:stream>")) {
            reset();
            onEnd();
        } else {
            buf = new StringBuf(); 
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
        //HACK:
        if(@:privateAccess cast(xml.elements(),haxe.iterators.ArrayIterator<Dynamic>).array.length == 1) {
           handleXML(xml.firstElement()); 
        } else {
            for(e in xml.elements()) {
                handleXML(e);
            }
        }
	}

	function handleXML(xml:XML) {
		if(xml.has(xmlns) && xml.get('xmlns') != xmlns) {
			trace("invalid stream namespace");
			return;
        }
        if(xml.has("id")) {
            final id = xml.get("id");
            if(queries.exists(id)) {
                final h = queries.get(id);
                queries.remove(id);
                h(xml);
                return;
            }
        }
		switch xml.name {
        case 'message': onMessage(xml);
        case 'presence': onPresence(xml);
        case 'iq':
            final iq:IQ = xml;
            switch iq.type {
            case Result, Error:
                if (queries.exists(iq.id)) {
                    final h = queries.get(iq.id);
                    queries.remove(iq.id);
                    h(iq);
                } else {
                    #if debug
                    trace('unhandled iq response');
                    #end
                }
            case Get, Set:
                if(iq.payload != null) {
                    final ns = iq.payload.xmlns;
                    if(features != null && features.exists(ns)) {
                        features.get(ns)(iq, (?res)->{
                            send((res==null)
                                ? iq.createError({ type:cancel, condition:feature_not_implemented })
                                : switch res {
                                    case Result(r): iq.createResult(r);
                                    case Error(e): iq.createError(e);
                                }
                            );
                        });
                    } else {
                        onIQ(iq, res -> {
                            send((res==null)
                                ? iq.createError({ type:cancel, condition:feature_not_implemented })
                                : switch res {
                                    case Result(r): iq.createResult(r);
                                    case Error(e): iq.createError(e);
                                }
                            );
                        });
                    }
                }
            }
        default:
            //TODO async handler
            if(!onRaw(xml)) {
                end();
            }
		}
	}

	function reset() {
		ready = false;
		queries = new Map();
		buf = new StringBuf();
	}
	
	public static function makeRandomId(seed:String='', length = 8) : String
		return Std.string(Md5.encode(seed + Date.now().getTime() + (Math.random()*1))).substr(0, length);

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
