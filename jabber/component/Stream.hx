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
class Stream extends jabber.Stream {
	
	public static inline var STANDARD_PORT = 5275;
	public static var defaultPort = STANDARD_PORT;
	
	public dynamic function onAuthenticated( s : Stream ) : Void;
	
	/** This components subdomain */
	public var sub(default,null) : String;
	
	/** Shared secret used to identify legacy components*/
	public var secret(default,null) : String;
	
	/** Indicates if the component is authenticated at server */
	public var authenticated(default,null) : Bool;
	
	/** */
	public var serviceListener(default,null) : ServiceDiscoveryListener;
	
	
	/**
	*/
	public function new( sub : String, secret : String, cnx : jabber.StreamConnection
						 /*,?identity : { category : String, name : String, type : String }*/ ) {
		if( sub == null || sub == "" ) throw "Invalid component subdomain specified";
		super( cnx, null );
		this.sub = sub;
		this.secret = secret;
		authenticated = false;
		serviceListener = new ServiceDiscoveryListener( this, { category : "component", name : "norc", type : "server-pc" } );
	}
	
	
	override function connectHandler() {
		sendData( xmpp.Stream.createOpenStream( xmpp.Stream.XMLNS_COMPONENT, sub ) );
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
		collectors.add( new PacketCollector( [ cast new xmpp.filter.PacketNameFilter( ~/handshake/ ) ], authCompleteHandler, false ) );
		var handshake = Xml.createElement( "handshake" );
		handshake.addChild( Xml.createPCData( crypt.SHA1.encode( id+secret ) ) );
		sendData( handshake.toString() );
	}
	
	function authCompleteHandler( p : xmpp.Packet ) {
		authenticated = true;
		onAuthenticated( this );
	}
	
}
