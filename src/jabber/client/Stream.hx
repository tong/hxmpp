package jabber.client;

import jabber.JID;
import jabber.core.StreamStatus;
import jabber.core.IStreamConnection;
import jabber.core.PacketCollector;
import jabber.core.PacketTimeout;
import xmpp.Message;
import xmpp.filter.PacketIDFilter;



/**
	Base for jabber streams between C2S.<br>
*/
class Stream extends jabber.core.StreamBase {
	
	public static inline var _DEFAULT_PORT = 5222;
	public static var DEFAULT_PORT = _DEFAULT_PORT;
	
	
	public var jid(default,null) : JID;
	public var host(getHost,null) : String;
	
	
	public function new( jid : JID, connection : IStreamConnection, ?version : String ) {
		super( connection, version );
		this.jid = jid;
	}
	
	
	function getHost() : String {
		return if( jid == null ) null else jid.domain;
	}
	
	
	override function onConnect() {
		status = StreamStatus.pending;
		sendData( xmpp.Stream.createOpenStream( xmpp.Stream.XMLNS_CLIENT, jid.domain, version, lang ) );
		connection.read( true ); // start reading input
	}
	
	override function onData( data : String ) {
		
		//super.onData( data );
		
		if( status == StreamStatus.closed ) return;
		data = StringTools.trim( data );
		
		if( status == StreamStatus.pending ) {
			if( xmpp.Stream.isStream( data ) ) {
				if( xmpp.Stream.getStreamType( data ) == "features" ) {
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
				onOpen.dispatchEvent( this );
				
			} else {
				throw "XMPP error";
			}
			
		} else if( status == StreamStatus.open ) {
			var xml : Xml = null;
			try {
				xml = Xml.parse( data );
			} catch( e : Dynamic ) {
				if( xmpp.Stream.isStream( data ) ) {
					if( data.indexOf( "stream:error" ) > -1 ) {
						trace( data.substr( data.indexOf("<stream:error"), data.lastIndexOf("/stream:error")+14 ) );
						//TODO parse stream:error
					}
					if( data.indexOf( "/stream:stream" ) > -1 ) {
						trace("STREAM CLOSED");
					}
				}
				trace("ERROr parsing xml " + data );
				/*
				if( data == "</stream:error>" ) {
					trace("STEEAM ERROR");
					//streamCloseHandler();
					onClose.dispatchEvent( this );
				}
				*/
			}
			collectPackets( xml );
		}
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
		return untyped sendPacket( new xmpp.Message( MessageType.normal, to, subject, message, null, jid.toString() ) );
	}
	
	//public function sendPresence()
	
	public function toString() : String {
		return "jabber.client.Stream("+jid+")";
	}
	
}
