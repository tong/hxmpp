package xmpp;

import xmpp.IQ;

/**
    Extension for communicatin blocking.

    [XEP-0191: Blocking Command](https://xmpp.org/extensions/xep-0191.html)
**/
@xep(191)
class Block {

	public static inline var XMLNS = 'urn:xmpp:blocking';

    /**
        Load list of blocked entities.
    **/
    public static inline function getBlocklist(stream: xmpp.Stream, handler: xmpp.Response<XML>->Void) : IQ {
        return stream.get(Payload.create(XMLNS, "blocklist"), handler);
    }

    /**
        Block recieving stanzas from entity.
    **/
    public static inline function block(stream: xmpp.Stream, jid: Jid, handler: xmpp.Response<XML>->Void) : IQ {
        return stream.set(Payload.create(XMLNS, "block").append(XML.create('item').set('jid', jid)), handler);
    }

    /**
        Unblock recieving stanzas from entity.
    **/
    public static function unblock(stream: Stream, ?jid: Jid, handler: xmpp.Response<XML>->Void) : IQ {
        var x = IQ.Payload.create(XMLNS, "unblock");
        if(jid != null) x.append(XML.create('item').set('jid', jid));
        return stream.set(x, handler);
    }
}
