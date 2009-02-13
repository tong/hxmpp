package xmpp;


/**
	<a href="http://xmpp.org/extensions/xep-0085.html">XEP-0085: Chat State Notifications</a><br/>
*/
enum ChatState {
	
	/**
		User is actively participating in the chat session.
		User accepts an initial content message, sends a content message, gives focus to the chat interface,
		or is otherwise paying attention to the conversation.
	*/
	active;
	
	/**
		User is composing a message.
		User is interacting with a message input interface specific to this chat session
		(e.g., by typing in the input area of a chat window).
	*/
	composing;
	
	/**
		User had been composing but now has stopped.
		User was composing but has not interacted with the message input interface for a short period of time
		(e.g., 5 seconds).
	*/
	paused;
	
	/**
		User has not been actively participating in the chat session.
		User has not interacted with the chat interface for an intermediate period of time (e.g., 30 seconds).
	*/
	inactive;
	
	/**
		User has effectively ended their participation in the chat session.
		User has not interacted with the chat interface, system, or device for a relatively long period of time
		(e.g., 2 minutes), or has terminated the chat interface (e.g., by closing the chat window).
	*/
	gone;
	
}
