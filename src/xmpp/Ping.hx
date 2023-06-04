package xmpp;

import xmpp.IQ;

/**
    Application-level pings.

    [XEP-0199](https://xmpp.org/extensions/xep-0199.html)
**/
@xep(199)
class Ping {

	public static inline var XMLNS = "urn:xmpp:ping";

    public static inline function ping(stream: Stream, ?jid: String, ?handler: Response<XML>->Void): IQ
        return stream.get(Payload.create(XMLNS, "ping"), jid, handler); 
}
