package xmpp;


/**
	<a href="http://xmpp.org/extensions/xep-0085.html">XEP-0085: Chat State Notifications</a><br/>
*/
class ChatStateExtension {
	
	public static var XMLNS = "http://jabber.org/protocol/chatstates";
	
	/**
		Adds (or changes if already has) the chat state property of the givent message packet.
	*/
	public static function set( m : xmpp.Message, state : ChatState ) : xmpp.Message {
		for( p in m.properties ) {
			switch( p.nodeName ) {
			case "active","composing","paused","inactive","gone" :
				m.properties.remove( p );
			}
		}
		m.properties.push( createXml( state ) );
		return m;
	}
	
	/**
		Creates a chat state extension xml.
	*/
	public static inline function createXml( state : ChatState ) : Xml {
		var x = Xml.createElement( Type.enumConstructor( state ) );
		x.set( "xmlns", XMLNS );
		return x;
	}
	
	/**
		Extracts the chat state of the given message.
		Returns null if no state was found.
	*/
	public static function get( m : xmpp.Message ) : xmpp.ChatState {
		for( e in m.properties ) {
			var s = e.nodeName;
			switch( s ) {
			case "active","composing","paused","inactive","gone" :
				return Type.createEnum( xmpp.ChatState, s );
			}
		}
		return null;
	}
	
	/**
	*/
	public static function getString( m : xmpp.Message ) : String {
		for( e in m.properties ) {
			var s = e.nodeName;
			switch( s ) {
			case "active","composing","paused","inactive","gone" : return s;
			}
		}
		return null;
	}
	
}
