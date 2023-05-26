package xmpp;

import xmpp.IQ;

/**
    Store any arbitrary XML on the server.

    [XEP-0049: Private XML Storage](https://xmpp.org/extensions/xep-0049.html)
**/
@xep(49)
class PrivateStorage {

	public static inline var XMLNS = "jabber:iq:private";

    /**
        Retrieve private data stored on server.
    **/
    public static inline function getPrivateStorage(stream: Stream, data: XML, handler: Response<Payload>->Void): IQ
        return stream.get(Payload.create(XMLNS).append(data), handler);

    /**
        Store private data on server.
    **/
    public static inline function setPrivateStorage(stream: Stream, data: XML, handler: Response<Payload>->Void) : IQ
        return stream.set(Payload.create(XMLNS).append(data), handler);
}
