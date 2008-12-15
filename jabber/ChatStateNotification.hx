package jabber;

import xmpp.MessageType;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketFieldFilter;


/**
	Extension for communicating the status of a user in a chat session.
	<a href="http://xmpp.org/extensions/xep-0085.html">XEP-0085: Chat State Notifications.</a><br/>
*/
class ChatStateNotification {
	
	/**
		The current state of this chat.
		If not null, messages sent to the peer jid of this chat will be intercepted with the state notification.
	*/
	public var state : xmpp.ChatState;
	public var chat(default,setChat) : Chat;
	public var featureName(default,null) : String;
	
	var f_message : MessageFilter;
	var f_to : PacketFieldFilter;
	var m : xmpp.Message;
	
	
	public function new( chat : Chat ) {
		
		m = new xmpp.Message( MessageType.chat );
		f_message = new MessageFilter( MessageType.chat );
		f_to = new PacketFieldFilter( "to", chat.peer );
		
		featureName = xmpp.ChatStateExtension.XMLNS;
		
		setChat( chat );
		
		chat.stream.addInterceptor( this );
	}
	
	
	function setChat( c : Chat ) : Chat {
		if( c == chat ) return c;
		m.to = c.peer;
		return chat = c;
	}
	
	
	public function interceptPacket( p : xmpp.Packet ) : xmpp.Packet {
		if( chat == null ) {
			chat.stream.removeInterceptor( this );
			return p;
		}
		if( state == null || !f_message.accept( p ) || !f_to.accept( p ) ) return p;
		xmpp.ChatStateExtension.set( untyped p, state );
		return p;
	}
	
	/**
		Force to send the current chat state in a standalone notification message.
	*/
	public function send( state : xmpp.ChatState ) : xmpp.Message {
		if( state == null ) throw new error.Exception( "Cannot set null chat state" );
		if( chat == null ) throw new error.Exception( "No chat given, cannot set chat state" );
		xmpp.ChatStateExtension.set( m, state );
		return chat.stream.sendPacket( m , false );
	}

}
