package jabber.component;

import jabber.JID;
import jabber.StreamStatus;
import jabber.core.PacketCollector;
import jabber.core.PacketCollector;
import jabber.core.PacketTimeout;
import xmpp.filter.PacketIDFilter;


/**
	Base for Component-2-Server jabber streams.<br/>
	<a href="http://www.xmpp.org/extensions/xep-0114.html">XEP-0114: Jabber Component Protocol</a>
*/
class Stream extends jabber.core.StreamBase {
	
	public static inline var STANDARD_PORT = 5275;
	public static var defaultPort = STANDARD_PORT;
	
	public var server(default,null) : String;
	public var password(default,null) : String;
	//public var service(default,null) : ServiceDiscovery;
	
	
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
//		service = new ServiceDiscovery( this );
		//service.listenInfoRequests = true;
	}
	
}
