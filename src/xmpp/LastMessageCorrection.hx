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
        message.properties.push(XML.create("replace").set('xmlns', XMLNS).set('id', id));
        return message;
	}

	/**
	   Get the id of the message corrected by the given message stanza, or `null` if it is no correction.
	**/
    public static function correction(message : xmpp.Message) : Null<String> {
        for (e in message.properties)
            if (e.name == "replace" && e.is(XMLNS))
                return e.get('id');
        return null;
	}

}
