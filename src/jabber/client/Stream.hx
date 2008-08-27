package jabber.client;

import jabber.JID;
import jabber.core.StreamStatus;
import jabber.core.IStreamConnection;
import jabber.core.PacketCollector;
import jabber.core.PacketTimeout;
import xmpp.Message;
import xmpp.filter.PacketIDFilter;


/*
class JabberServer {
	public var host : String;
}
*/

/**
	Base for jabber streams between C2S.<br>
*/
class Stream extends jabber.core.StreamBase {
	
	public static inline var STANDARD_PORT = 5222;
	public static var DEFAULT_PORT = STANDARD_PORT;
	
	
	public var jid(default,null) : JID;
	public var host(getHost,null) : String;
	
	
	public function new( jid : JID, connection : IStreamConnection, ?version : String ) {
		super( connection, version );
		this.jid = jid;
	}
	
	
	function getHost() : String {
		return if( jid == null ) null else jid.domain;
	}
	
	
	/**
		Sends an IQ xmpp packet and forwards the collected response to the given handler function.
	*/
	public function sendIQ( iq : xmpp.IQ, handler : xmpp.IQ->Void,
							?permanent : Bool, ?timeout : PacketTimeout, ?block : Bool ) {
		iq.id = nextID();
		collectors.add( new PacketCollector( [new PacketIDFilter( iq.id )], handler, permanent, timeout, block ) );
		sendPacket( iq );
		//return { iq : iq, collector : IPacketCollector };
	}
	
	/**
		Sends a "normal" type message.
	*/
	public function sendMessage( to : String, subject : String, message : String ) : xmpp.Message {
		//return untyped sendPacket( new xmpp.Message( MessageType.normal, to, subject, message, null, jid.toString() ) );
		return cast( sendPacket( new xmpp.Message( MessageType.normal, to, subject, message, null, jid.toString() ) ), xmpp.Message );
	}
	
	//public function sendPresence()
	
	public function toString() : String {
		return "jabber.client.Stream("+jid+")";
	}
	
	
	override function connectHandler() {
		status = StreamStatus.pending;
		sendData( xmpp.XMPPStream.createOpenStream( xmpp.XMPPStream.XMLNS_CLIENT, jid.domain, version, lang ) );
		connection.read( true ); // start reading input
	}
	
	override function dataHandler( data : String ) {
		
		switch( status ) {
			
			case StreamStatus.closed : return;
			
			case StreamStatus.pending :
				
				#if XMPP_DEBUG
				trace( "XMPP <<< " + data );
				#end
				
				data = util.StringUtil.removeXmlHeader( data );
				var sei = data.indexOf( ">" );
				
				if( id == null ) {
					
					var s = data.substr( 0, sei ) + " />";
					var sx = Xml.parse( s ).firstElement();
					id = sx.get( "id" );
					
					if( version == null ) {
						status = StreamStatus.open;
						onOpen.dispatchEvent( this );
						return;
					}
				}
				
				if( id == null ) throw "Invalid xmpp stream, no id.";
				
				var sfi =  data.indexOf( "<stream:features>" );
				var sf = data.substr( data.indexOf( "<stream:features>" ) );
				if( sfi != -1 ) {
					parseStreamFeatures( Xml.parse( sf ).firstElement() );
					if( status != StreamStatus.open ) {
						status = StreamStatus.open;
						onOpen.dispatchEvent( this );
					}
				}
			
			case StreamStatus.open :
			
				if( data.substr( 0, 13 ) == "<stream:error" ) {
					var error = xmpp.XMPPStreamError.parse( Xml.parse( data.substr( 0, data.indexOf( "</stream:error>" )+15 ) ).firstElement() );
					onError.dispatchEvent( { stream : cast( this, jabber.core.StreamBase ),  error : error } );
				}
				var i = data.indexOf( "</stream:stream>" );
				if( i != -1 ) {
					connection.disconnect();
					onClose.dispatchEvent( this );
					return;
				}
				
				var xml : Xml = null;
				try {
					xml = Xml.parse( data );
				} catch( e : Dynamic ) {
					throw "Invalid xmpp " + data;
				}
				
				if( xml != null ) {
					var packets = collectPackets( xml );
					for( packet in packets ) {
					//	onXMPP.dispatchEvent( new jabber.event.XMPPEvent( this, packet ) );
					}
					
				}
		}
	}
	
	function parseStreamFeatures( src : Xml ) {
		//TODO
		//trace("parseStreamFeatures");
	}
	
}
