package xmpp;

typedef TDelay = {

    /**
        The Jabber ID of the entity that originally sent the XML stanza or that delayed the delivery of the stanza (e.g., the address of a multi-user chat room).
    **/
    from : String,

    /**
        The time when the XML stanza was originally sent.
    **/
    stamp: String,

    /**
        Natural-language description of the reason for the delay.
    **/
    ?description: String
}

/**
    Communicate the fact that an XML stanza has been delivered with a delay.

    [XEP-0203: Delayed Delivery](https://xmpp.org/extensions/xep-0203.html)
**/
@xep(203)
class DelayedDelivery {

	public static inline var XMLNS = "urn:xmpp:delay";

    public static function delay(stanza: xmpp.Message) : TDelay {
        for(e in stanza.properties)
            if(e.is(XMLNS))
                return { from: e["from"], stamp: e["stamp"], description: e.text };
        return null;
    }
}
