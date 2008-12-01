package jabber.component;

import jabber.JID;
import jabber.StreamStatus;
import jabber.ServiceDiscovery;
import jabber.ServiceDiscoveryListener;
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
	
	public dynamic function onAuthenticated( stream : Stream ) : Void;
	
	/** */
	//public var server(default,null) : String;
	public var host(default,null) : String;
	/** Shared secret used to identify legacy components*/
	public var password(default,null) : String;
	/** */
	public var authenticated(default,null) : Bool;
	/** */
	public var serviceListener(default,null) : ServiceDiscoveryListener;
	

	public function new( host : String, password : String, cnx : jabber.StreamConnection ) {
		
		super( cnx );
		this.host = host;
		this.password = password;
		
		authenticated = false;
	}
	
	
	override function connectHandler() {
		sendData( xmpp.XMPPStream.createOpenStream( xmpp.XMPPStream.XMLNS_COMPONENT, host ) );
		status = StreamStatus.pending;
		connection.read( true );
	}

	override function dataHandler( data : String ) {
		super.dataHandler( data );
		switch( status ) {
			case closed : return;
			case pending :
			case open : collectPackets( Xml.parse( data ) );
		}
	}
	
	override function processStreamInit( s : String ) {
		var d = util.XmlUtil.removeXmlHeader( s );
		var dx = Xml.parse( d+"</stream:stream>" ).firstChild();
		id = dx.get( "id" );
		status = StreamStatus.open;
		onOpen( this );
		collectors.add( new PacketCollector( [ cast new xmpp.filter.PacketNameFilter( ~/handshake/ ) ], handshakeResponseHandler, false ) );
		var handshake = Xml.createElement( "handshake" );
		handshake.addChild( Xml.createPCData( crypt.SHA1.encode( id+password ) ) );
		sendData( handshake.toString() );
	}
	
	function handshakeResponseHandler( p : xmpp.Packet ) {
		serviceListener = new ServiceDiscoveryListener( this, { category : "component", name : "norc", type : "server-pc" } );
		authenticated = true;
		onAuthenticated( this );
	}
	
}
