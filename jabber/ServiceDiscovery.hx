package jabber;

import jabber.stream.PacketCollector;
import xmpp.filter.IQFilter;


/**
	Manages discovery of services from XMPP entities.<br>
	Two kinds of information can be discovered:<br>
	(1) the identity and capabilities of an entity, including the protocols and features it supports,<br>
	(2) the items associated with an entity, such as the list of rooms hosted at a multi-user chat service.<br>
	
	<a href="http://www.xmpp.org/extensions/xep-0030.html">XEP 30 - ServiceDiscovery</a>
*/
class ServiceDiscovery {
	
	public dynamic function onInfo( node : String, data : xmpp.disco.Info ) : Void;
	public dynamic function onItems( node : String, data : xmpp.disco.Items ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	
	
	public function new( stream : jabber.Stream ) {
		this.stream = stream;
	}
	
	
	/**
		Queries entity for information.
	*/
	public function discoverInfo( jid : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.get, null, jid );
		iq.ext = new xmpp.disco.Info();
		stream.sendIQ( iq, handleInfoResponse, false );
	}
	
	/**
		Queries entity for items.
	*/
	public function discoverItems( jid : String, ?node : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.get, null, jid );
		iq.ext = new xmpp.disco.Items( node );
		stream.sendIQ( iq, handleItemsResponse, false );
	}
	
	
	function handleInfoResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result : onInfo( iq.from, xmpp.disco.Info.parse( iq.ext.toXml() ) );
			case error : onError( new jabber.XMPPError( this, iq ) );
			default : // #
		}
	}
	
	function handleItemsResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result : onItems( iq.from, xmpp.disco.Items.parse( iq.ext.toXml() ) );
			case error : onError( new jabber.XMPPError( this, iq ) );
			default: // #
		}
	}
	
}
