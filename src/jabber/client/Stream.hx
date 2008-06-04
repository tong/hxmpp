package jabber.client;

import jabber.JID;
import jabber.StreamStatus;
import jabber.IStreamConnection;
import jabber.PacketCollector;
import jabber.PacketTimeout;
import xmpp.Message;
import xmpp.filter.PacketIDFilter;



/**
	Abstract base for jabber streams from C2S.
*/
class Stream extends jabber.StreamBase {
	
	public static inline var XMLNS = "jabber:client";
	public static var DEFAULT_PORT = 5222;
	
	
	public var jid(default,null) : JID;
	//public var password(default,setPassword) : String;
	//TODO: global presence? : IPresenceListener;
	
	
	public function new( jid : JID, connection : IStreamConnection, ?version : String ) {
		super( connection, version );
		this.jid = jid;
	}
	
	
	override function onConnect() {
		trace("onConnect");
		status = StreamStatus.pending;
		sendData( xmpp.Stream.createOpenStream( XMLNS, jid.domain, version, lang ) );
		connection.read( true ); // start reading stream data
	}
	
	/**
	*/
	override function onData( data : String ) {
		trace(data);
		
		if( status == StreamStatus.closed ) return;
		data = StringTools.trim( data );
		
		if( status == StreamStatus.pending ) {
			if( xmpp.Stream.isStream( data ) ) {
				if( xmpp.Stream.getStreamType( data ) == "features" ) {
					parseStreamFeatures( Xml.parse( data ).firstElement() );
					return;
				}
				data = util.StringUtil.removeXmlHeader( data );
				var s : String;
				if( data.substr( data.indexOf("><") + 2, 15 ) == "stream:features" ) {
					var i = data.indexOf("><") + 1;
					s = data.substr( 0, i );
					var f = data.substr( i );
					parseStreamFeatures( Xml.parse( f ).firstElement() );
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
			var xml : Xml;
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
		Sends an IQ xmpp packet and forwards the response to the defined handler function.
	*/
	public function sendIQ( iq : xmpp.IQ, handler : xmpp.IQ->Void,
							?permanent : Bool, ?timeout : PacketTimeout, ?block : Bool ) {
		iq.id = nextID();
		collectors.add( new PacketCollector( [new PacketIDFilter( iq.id )], handler, permanent, timeout, block ) );
		sendPacket( iq );
	}
	
	/**
		Sends a "normal" type message.
	*/
	public function sendMessage( to : String, subject : String, message : String ) {
		sendPacket( new xmpp.Message( MessageType.normal, to, subject, message, null, jid.toString() ) );
	}
	
	
	public function toString() : String {
		return "jabber.client.Stream("+jid+")";
	}
}
