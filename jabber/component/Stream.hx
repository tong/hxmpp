package jabber.component;

import jabber.JID;
import jabber.StreamStatus;
import jabber.core.PacketCollector;
import jabber.core.PacketCollector;
import jabber.core.PacketTimeout;
import xmpp.filter.PacketIDFilter;


/**
	Base for component2server jabber streams.
	<a href="http://www.xmpp.org/extensions/xep-0114.html">XEP-0114: Jabber Component Protocol</a>
*/
class Stream extends jabber.core.StreamBase {
	
	public static inline var STANDARD_PORT = 5275;
	public static var DEFAULT_PORT = STANDARD_PORT;
	
	public var server(default,null) : String;
	public var password(default,null) : String;
	public var service(default,null) : ServiceDiscovery;
	
	
	public function new( server : String, password : String, connection : jabber.core.StreamConnection ) {
		super( connection );
		this.server = server;
		this.password = password;
	}
	
	
	override function connectHandler() {
		sendData( xmpp.XMPPStream.createOpenStream( xmpp.XMPPStream.XMLNS_COMPONENT, server ) );
		status = StreamStatus.pending;
		connection.read( true ); // start reading io data
	}

	override function dataHandler( data : String ) {
		super.dataHandler( data );
		switch( status ) {
			case closed :
				return;
			case pending :
				
			case open :
				collectPackets( Xml.parse( data ) );
		}
	}
	
	override function processStreamInit( s : String ) {
		var data = util.XmlUtil.removeXmlHeader( s );
		var dx = Xml.parse( data + "</stream:stream>" ).firstChild();
		id = dx.get( "id" );
		status = StreamStatus.open;
		collectors.add( new PacketCollector( [ cast new xmpp.filter.PacketNameFilter( "handshake" ) ], handshakeResponseHandler, false ) );
		var handshake = Xml.createElement( "handshake" );
		handshake.addChild( Xml.createPCData( crypt.SHA1.encode( id + password ) ) );
		sendData( handshake.toString() );
	}
	
	function handshakeResponseHandler( p : xmpp.Packet ) {
		service = new ServiceDiscovery( this );
		//service.listenInfoRequests = true;
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
}
