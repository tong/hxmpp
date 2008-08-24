package jabber.component;

import jabber.JID;
import jabber.core.StreamStatus;
import jabber.core.PacketCollector;



/**
	Base for component2server jabber streams.
*/
class Stream extends jabber.core.StreamBase {
	
	public static inline var STANDARD_PORT = 5275;
	public static var DEFAULT_PORT = STANDARD_PORT;
	
	
	public var name(default,null) : String;
	public var password(default,null) : String;
	
	
	public function new( name : String, password : String, connection : jabber.core.IStreamConnection ) {
		super( connection );
		this.name = name;
		this.password = password;
	}
	
	
	override function onConnect() {
		sendData( xmpp.XMPPStream.createOpenStream( xmpp.XMPPStream.XMLNS_COMPONENT, name ) );
		status = StreamStatus.pending;
		connection.read( true ); // start reading io data
	}

	override function onData( data : String ) {
		
		#if XMPP_DEBUG
		trace( "XMPP<<< " + data + "\n", false );
		#end
		
		if( status == StreamStatus.closed ) return;
//		if( data.length < 2 ) return;
		data = StringTools.trim( data );
		
		if( status == StreamStatus.pending ) {
			if( xmpp.XMPPStream.isStream( data ) ) {
				data = util.StringUtil.removeXmlHeader( data );
				var dx = Xml.parse( data + "</stream:stream>" ).firstChild();
				id = dx.get( "id" );
				status = StreamStatus.open;
				collectors.add( new PacketCollector( [ new xmpp.filter.PacketNameFilter( "handshake" ) ], handshakeResponseHandler, false ) );
				var handshake = Xml.createElement( "handshake" );
				handshake.addChild( Xml.createPCData( crypt.SHA1.encode( id + password ) ) );
				sendData( handshake.toString() );
			} 
		} else {
			collectPackets( Xml.parse( data ) );
		}
	}

	function handshakeResponseHandler( p : xmpp.Packet ) {
		trace( p );
		//service disco
	}
	
}
