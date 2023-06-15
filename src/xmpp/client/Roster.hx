package xmpp.client;

import xmpp.IQ;
import xmpp.Presence;

enum abstract AskType(String) from String to String {

	/**
        Denotes that  a request to subscribe to a entities presence has been made.
    **/
	var subscribe;

	/**
        Denotes that a request to unscubscribe from a users presence has been made.
    **/
	var unsubscribe;
}

/**
    A user's roster is stored by the user's server on the user's behalf so that the user can access roster information from any device.

    @see https://xmpp.org/rfcs/rfc6121.html#roster
**/
class Roster {

    public static inline var XMLNS = "jabber:iq:roster";

    public static inline function getRoster(stream: Stream, handler : Response<XML>->Void) : IQ
        return stream.get(XMLNS, null, handler);

    public static function addRosterItem(stream: Stream, jid:String, name: String, ?groups:Array<String>, handler: Response<XML>->Void) : IQ {
        final item = XML.create("item").set("jid", jid).set("name", name);
        if(groups != null) for(g in groups) item.append(XML.create('group',g));
        return stream.set(Payload.create(XMLNS).append(item), handler);
    }

    public static function removeRosterItem(stream: Stream, jid:String, handler: Response<XML>->Void) : IQ {
        return stream.set(Payload.create(XMLNS)
            .append(XML.create("item")
                .set("jid", jid)
                .set("subscription", "remove")), handler);
    }

    public static function subscribePresence(stream: Stream, jid: String) {
        var p = new Presence();
        p.to = jid;
        p.type = subscribe;
        p.id = xmpp.Stream.makeRandomId();
        stream.send(p);
    }

    public static function unsubscribePresence(stream: Stream, jid: String) {
        var p = new Presence();
        p.to = jid;
        p.type = unsubscribed;
        p.id = xmpp.Stream.makeRandomId();
        stream.send(p);
    }
}
