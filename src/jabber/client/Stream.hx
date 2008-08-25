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
		
		#if XMPP_DEBUG
		trace( "XMPP <<< " + data );
		#end
		
		switch( status ) {
			
			case StreamStatus.closed : return;
			
			case StreamStatus.pending :
			
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
				
				var sfi =  data.indexOf("<stream:features>");
//				trace(sfi+"");
				var sf = data.substr( data.indexOf( "<stream:features>" ) );
				if( sfi != -1 ) {
//					trace("################################################ " + sf + "\n\n");
					parseStreamFeatures( Xml.parse( sf ).firstElement() );
					if( status != StreamStatus.open ) {
						status = StreamStatus.open;
						onOpen.dispatchEvent( this );
					}
				}
			
			case StreamStatus.open :
				trace("OPEN");
				var xml : Xml = null;
				try {
					xml = Xml.parse( data );
				} catch( e : Dynamic ) {
					trace("Error?");
					trace( e );
				}
				if( xml != null ) {
					collectPackets( xml );
				}
		}
		
		///////////////////////////////////////////////////////////
		
		/*
		if( status == StreamStatus.closed ) return;
		data = StringTools.trim( data );
		
		if( status == StreamStatus.pending ) {
			if( xmpp.XMPPStream.isStream( data ) ) {
				if( xmpp.XMPPStream.getStreamType( data ) == "features" ) {
//					parseStreamFeatures( Xml.parse( data ).firstElement() );
					return;
				}
				data = util.StringUtil.removeXmlHeader( data );
				var s : String;
				if( data.substr( data.indexOf("><") + 2, 15 ) == "stream:features" ) {
					var i = data.indexOf("><") + 1;
					s = data.substr( 0, i );
					var f = data.substr( i );
//					parseStreamFeatures( Xml.parse( f ).firstElement() );
				} else {
					s = data;
				}
				var sx = Xml.parse( s + "</stream:stream>" ).firstChild();
				id = sx.get( "id" );
				if( id == null || id.length < 2 ) {
					throw "Invalid stream response, no id specified";
				}
				status = StreamStatus.open;
				#if JABBER_DEBUG
				trace( "Jabber stream to " +jid.domain+ " opened.\n" );
				#end
				onOpen.dispatchEvent( this );
				
			} else {
				throw "XMPP error";
			}
			
		} else if( status == StreamStatus.open ) {
			var xml : Xml = null;
			try {
				xml = Xml.parse( data );
			} catch( e : Dynamic ) {
				if( xmpp.XMPPStream.isStream( data ) ) {
					if( data.indexOf( "stream:error" ) > -1 ) {
						trace( data.substr( data.indexOf("<stream:error"), data.lastIndexOf("/stream:error")+14 ) );
						//TODO parse stream:error
					}
					if( data.indexOf( "/stream:stream" ) > -1 ) {
						trace("STREAM CLOSED");
					}
				}
				trace("ERROr parsing xml " + data );
				//if( data == "</stream:error>" ) {
				//	trace("STEEAM ERROR");
				//	//streamCloseHandler();
				//	onClose.dispatchEvent( this );
				//}
			}
			collectPackets( xml );
		}
		*/
	}
	
	function parseStreamOpen( src : String ) {
	}
	
	function parseStreamFeatures( src : Xml ) {
		//TODO
		trace("parseStreamFeatures");
	}
	
}













/*
FUCKED DATAHANDLERS


		switch( status ) {
		
			case StreamStatus.closed : return;
			
			case StreamStatus.pending :
				
				trace( "PENDING " );
			
				//data = StringTools.trim( data );
				data = util.StringUtil.removeXmlHeader( data );
				var sei = data.indexOf( ">" );

				if( id == null ) {
					
					var s = data.substr( 0, sei ) + " />";
					var sx = Xml.parse( s ).firstElement();
					id = sx.get( "id" );
					
					if( version != "1.0" ) {
						status = StreamStatus.open;
						onOpen.dispatchEvent( this );
						return;
					}
					
				}
				
				trace(status);
				trace( "änd ################################ " );
				var sf = data.substr( sei+1 );
				if( sf.length > 0 ) {
					trace("PARSE FEATUERS");
					//trace(sf+"");
					//var sfx = Xml.parse( sf ).firstElement();
					//trace(sfx.toString());
					//parseStreamFeatures( sfx );
					status = StreamStatus.open;
					onOpen.dispatchEvent( this );
					trace( "################################ " );
				}
				
				
			case StreamStatus.open :
			 
				trace("OPEN");
				
				var xml : Xml = null;
				try {
					xml = Xml.parse( data );
				} catch( e : Dynamic ) {
					trace("STREAM Error");
					trace( e );
				}
				
				if( xml != null ) collectPackets( xml );
		
		}


*/
