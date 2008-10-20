package xmpp;


class ChatStatePacket {
	
	public static var XMLNS = "http://jabber.org/protocol/chatstates";
	
	/**
		Adds the given state to the properties of this package.
	*/
	public static inline function add( m : xmpp.Message, state : ChatState ) : xmpp.Message {
		m.properties.push( createXml( state ) );
		return m;
	}
	
	/**
		Creates a chatstate extension xml.
	*/
	public static function createXml( state : ChatState ) : Xml {
		var x = Xml.createElement( Type.enumConstructor( state ) );
		x.set( "xmlns", XMLNS );
		return x;
	}
	
	/**
		Extracts the chat state of the given message.
		Returns null if no state was found.
	*/
	public static function getState( m : xmpp.Message ) : xmpp.ChatState {
		for( e in m.properties ) {
			var n = e.nodeName;
			switch( n ) {
				case "active","composing","paused","inactive","gone" :
					return Type.createEnum( xmpp.ChatState, n );
			}
		}
		return null;
	}
	
}
