package jabber.client;

import jabber.JID;
import jabber.StreamStatus;
import jabber.core.PacketCollector;
import jabber.core.PacketTimeout;
import jabber.core.StreamConnection;
import xmpp.Message;
import xmpp.filter.PacketIDFilter;


/**
	Basic C2S jabber stream.<br>
*/
class Stream extends jabber.core.StreamBase {
	
	public static inline var STANDARD_PORT = 5222;
	public static var DEFAULT_PORT = STANDARD_PORT;
	
	public var jid(default,null) : JID;
	
	
	public function new( jid : JID, connection : StreamConnection, ?version : String ) {
		super( connection, version );
		this.jid = jid;
	}
	
	
	/**
		Sends a "normal" type message.
	*/
	public function sendMessage( to : String, subject : String, message : String ) : xmpp.Message {
		return cast sendPacket( new xmpp.Message( xmpp.MessageType.normal, to, subject, message, null, jid.toString() ) );
	}
	
	/**
		Sends a "chat" type message.
	*/
	public function sendChatMessage( to : String, message : String ) : xmpp.Message {
		return cast sendPacket( new xmpp.Message( xmpp.MessageType.chat, to, null, message, null, jid.toString() ) );
	}
	
	/**
		Sends an IQ xmpp packet and forwards the collected response to the given handler function.
	*/
	//TODO ?timeout : TPacketTimeout
	public function sendIQ( iq : xmpp.IQ, handler : xmpp.IQ->Void,
							?permanent : Bool, ?timeout : PacketTimeout, ?block : Bool ) {
		iq.id = nextID();
		collectors.add( new PacketCollector( [cast new PacketIDFilter( iq.id )], handler, permanent, timeout, block ) );
		sendPacket( iq );
		//return { iq : iq, collector : IPacketCollector };
	}
	
	
	// client specific stream-open parsing.
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
