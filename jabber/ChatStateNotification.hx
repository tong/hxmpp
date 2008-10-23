package jabber;

import xmpp.MessageType;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketFieldFilter;


/**
	Extension for communicating the status of a user in a chat session.
	<a href="http://xmpp.org/extensions/xep-0085.html">XEP-0085: Chat State Notifications.</a><br/>
*/
class ChatStateNotification implements jabber.core.IPacketInterceptor {
	
	/**
		The current state of this chat.
		If not null, messages sent to the peer jid of this chat will be intercepted with the state notification.
	*/
	public var state : xmpp.ChatState;
	public var chat(default,setChat) : Chat;
	public var featureName(default,null) : String;
	
	var filter_message : MessageFilter;
	var filter_to : PacketFieldFilter;
	var message : xmpp.Message;
	
	
	public function new( chat : Chat ) {
		
		message = new xmpp.Message( MessageType.chat );
		filter_message = new MessageFilter( MessageType.chat );
		filter_to = new PacketFieldFilter( "to", chat.peer );
		
		featureName = xmpp.ChatStatePacket.XMLNS;
		
		setChat( chat );
		
		chat.stream.interceptors.add( this );
	}
	
	
	function setChat( c : Chat ) : Chat {
		if( c == chat ) return c;
		Reflect.setField( this, "chat", c );
		message.to = filter_to.value = chat.peer;
		return chat;
	}
	
	
	public function interceptPacket( p : xmpp.Packet ) : xmpp.Packet {
		if( chat == null ) {
			chat.stream.interceptors.remove( this );
			return p;
		}
		if( state == null || !filter_message.accept( p ) || !filter_to.accept( p ) ) return p;
		xmpp.ChatStatePacket.add( untyped p, state );
		return p;
	}
	
	/**
		Force to send the current chat state in a empty message.
	*/
	public function send( state : xmpp.ChatState ) : xmpp.Message {
		if( state == null ) throw new error.Exception( "Cannot set null chat state" );
		if( chat == null ) throw new error.Exception( "No chat given, cannot set chat state" );
		this.state = state;
		xmpp.ChatStatePacket.add( message, state );
		chat.stream.sendPacket( message, false );
		return message;
	}
	
/*	
	public static function add( m : xmpp.Message, state : xmpp.ChatState ) {
		xmpp.ChatStatePacket.add( m, state );
	}
*/

}
