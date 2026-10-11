package xmpp;

import xmpp.IQ;

/**
    [XEP-0066: Out of Band Data](https://xmpp.org/extensions/xep-0066.html)
**/
@xep(66)
class Oob {

	public static inline var XMLNS = "jabber:iq:oob";
	public static inline var XMLNS_X = "jabber:x:oob";

    /**
        Initiate an out-of-band file transfer with an intended recipient.
    **/
    public static function oob(stream: Stream, jid: Jid, url: String, ?description: String, ?sid: String, res:Response<XML>->Void):IQ {
        final x = Payload.create(XMLNS).append(XML.create("url",url));
        if(description != null) x.append(XML.create("description", description));
        if(sid != null) x.set("sid", sid);
        return stream.set(x, jid, res);
    }

    /**
        Get the oob property of given `xmpp.Message` stanza.
    **/
    public static function getOob(message:Message) : XML {
        for(e in message.properties) if(e.get("xmlns") == XMLNS_X) return e;
        return null;
    }

    /**
        Add a oob property to given `xmpp.Message` stanza.
    **/
    public static function setOob(message: Message, url: String, ?description: String):Message {
        final x = Payload.create(XMLNS_X, "x").append(XML.create("url",url));
        if(description != null) x.append(XML.create("description", description));
        message.properties.push(x);
        return message;
    }
}
