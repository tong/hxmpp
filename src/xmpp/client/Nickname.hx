package xmpp.client;

/**
    Communicate user nickname.

    @see [XEP-0172: User Nickname](https://xmpp.org/extensions/xep-0172.html)
**/
@xep(172)
class Nickname {

	public static inline var XMLNS = "http://jabber.org/protocol/nick";

    /**
        A global and memorable (but not necessarily unique) friendly name or informal name asserted by an IM user. 
    **/
    public static function nickname<T:Stanza>(stanza: T, name: String) : T {
        stanza.properties.push(XML.create("nick", name).set("xmlns", XMLNS));
        return stanza;
    }

    // macro public static function nickname(stanza: ExprOf<Stanza>, ?name: ExprOf<String>) {
    //     return macro $stanza.get;
    // }
}
