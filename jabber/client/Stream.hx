package jabber.client;

import jabber.JID;
import jabber.StreamStatus;
import jabber.core.StreamConnection;
import xmpp.Message;


/**
	Base for Client-2-Server jabber streams.<br>
*/
class Stream extends jabber.core.StreamBase {
	
	public static inline var STANDARD_PORT = 5222;
	public static var defaultPort = STANDARD_PORT;
	
	public var jid(default,null) : JID;
	
	
	public function new( jid : JID, connection : StreamConnection, ?version : String = "1.0" ) {
		super( connection, version );
		this.jid = jid;
	}
	
	
	/**
		Sends a "normal" type message.
	*/
	public function sendMessage( to : String, subject : String, msg : String ) : xmpp.Message {
		return sendPacket( new Message( xmpp.MessageType.normal, to, subject, msg, null, jid.toString() ) );
	}
	
	/**
		Sends a "chat" type message.
	*/
	public function sendChatMessage( to : String, msg : String ) : xmpp.Message {
		return sendPacket( new Message( xmpp.MessageType.chat, to, null, msg, null, jid.toString() ) );
	}
	
	
	override function processStreamInit( d : String ) {
		var sei = d.indexOf( ">" );
		if( id == null ) {
			// parse open stream
			var s = d.substr( 0, sei ) + " />";
			var sx = Xml.parse( s ).firstElement();
			id = sx.get( "id" );
			if( version == null ) {
				status = StreamStatus.open;
				onOpen( this );
				return;
			}
		}
		if( id == null ) throw "Invalid xmpp stream, no id.";
		// check for stream features
		var sfi =  d.indexOf( "<stream:features>" );
		var sf = d.substr( d.indexOf( "<stream:features>" ) );
		if( sfi != -1 ) {
			parseStreamFeatures( Xml.parse( sf ).firstElement() );
			if( status != StreamStatus.open ) {
				status = StreamStatus.open;
				onOpen( this );
			}
		}
	}
	
	override function connectHandler() {
		status = StreamStatus.pending;
		sendData( xmpp.XMPPStream.createOpenStream( xmpp.XMPPStream.XMLNS_CLIENT, jid.domain, version, lang ) );
		connection.read( true ); // start reading input
	}
	
}
