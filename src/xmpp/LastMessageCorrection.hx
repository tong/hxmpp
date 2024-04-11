package xmpp;

/**
    Indicate that a message is a correction of the last sent message.

    @see [XEP-0308: Last Message Correction](https://xmpp.org/extensions/xep-0308.html)
**/
@xep(308)
class LastMessageCorrection {

	public static inline var XMLNS = "urn:xmpp:message-correct:0";

	/**
        Add a message correction property to the given message stanza.
	**/
	public static inline function correct(message : xmpp.Message, id: String) : xmpp.Message {
        message.properties.push(XML.create("replace").set('xmlns', XMLNS));
        return message;//
	}

	/**
	   Get the correction id of the given message stanza.
	**/
    public static inline function correction(message : xmpp.Message) : String {
        return message.properties.filter(e -> return e.is(XMLNS))[0].get('id');
	}

}
