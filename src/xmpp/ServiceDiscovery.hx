package xmpp;

import xmpp.IQ;

/**
    Discover information about other XMPP entities.

    [XEP-0030: Service Discovery](https://xmpp.org/extensions/xep-0030.html)
**/
@xep(30)
class ServiceDiscovery {

    public static inline var XMLNS       = "http://jabber.org/protocol/disco";
    public static inline var XMLNS_INFO  = '$XMLNS#info';
    public static inline var XMLNS_ITEMS = '$XMLNS#items';

    /**
        Discover the identity and capabilities of an entity, including the protocols and features it supports.
    **/
    public static inline function discoInfo(stream: Stream, ?jid: Jid, handler: (res:Response<Payload>)->Void) : IQ {
        return stream.get(XMLNS_INFO, jid ?? stream.domain, handler);
    }

    /**
        Discover the items associated with an entity, such as the list of rooms hosted at a multi-user chat service.
    **/
    public static inline function discoItems(stream: Stream, ?jid: Jid, handler: Response<Payload>->Void): IQ {
        return stream.get(XMLNS_ITEMS, jid ?? stream.domain, handler);
    }
}
