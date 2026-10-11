package xmpp;

enum abstract TChatState(String) from String to String {
	/**
		User is actively participating in the chat session.
		User accepts an initial content message, sends a content message, gives focus to the chat interface,
		or is otherwise paying attention to the conversation.
	**/
	var active;

	/**
		User is composing a message.
		User is interacting with a message input interface specific to this chat session
		(e.g., by typing in the input area of a chat window).
	**/
	var composing;

	/**
		User had been composing but now has stopped.
		User was composing but has not interacted with the message input interface for a short period of time
		(e.g., 5 seconds).
	**/
	var paused;

	/**
		User has not been actively participating in the chat session.
		User has not interacted with the chat interface for an intermediate period of time (e.g., 30 seconds).
	**/
	var inactive;

	/**
		User has effectively ended their participation in the chat session.
		User has not interacted with the chat interface, system, or device for a relatively long period of time
		(e.g., 2 minutes), or has terminated the chat interface (e.g., by closing the chat window).
	**/
	var gone;
}

/**
	[XEP-0085: Chat State Notifications](https://xmpp.org/extensions/xep-0224.html)

	Communicates the status of a user in a chat session, thus indicating whether a chat partner is actively engaged in the chat, composing a message, temporarily paused, inactive, or gone.
**/
@xep(85)
class ChatState {
	public static inline var XMLNS = "http://jabber.org/protocol/chatstates";

	/**
		Extract the chatstate property of the message stanze.
	**/
	public static function getChatState(message:xmpp.Message):TChatState {
		for (e in message.properties)
			if (e.is(XMLNS))
				return e.name;
		return null;
	}

	/**
		Adds the chatstate property to the givent message stanza.
	**/
	public static inline function setChatState(message:xmpp.Message, state:TChatState):xmpp.Message {
		message.properties.push(XML.create(state).set('xmlns', XMLNS));
		return message;
	}

	/**
		Remove the chatstate property from the given message stanza.
	**/
	public static inline function removeChatState(message:xmpp.Message):xmpp.Message {
		for (e in message.properties.copy())
			if (e.is(XMLNS))
				message.properties.remove(e);
		return message;
	}
}
