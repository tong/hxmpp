package xmpp;

/**
    Extension for getting the attention of another user.

    [XEP-0224: Attention](https://xmpp.org/extensions/xep-0224.html)
**/
@xep(224)
class Attention {

	public static inline var XMLNS = "urn:xmpp:attention:0";

	/**
	    Sends a message packet to the given entity inluding a property to get attention.
	**/
	public static inline function captureAttention(message : xmpp.Message) : xmpp.Message {
        message.properties.push(XML.create("attention").set('xmlns', XMLNS));
        return message;
	}

    /**
        Return `true` if the message stanza includes an `<attention/>` element.
    **/
	public static inline function wantsAttention(message : xmpp.Message) : Bool {
        return message.properties.filter(e -> return e.is(XMLNS)).length > 0;
    }
}
