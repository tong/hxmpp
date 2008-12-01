package jabber;

import jabber.Stream;
import jabber.core.PacketCollector;
import jabber.event.IQResult;
import xmpp.IQ;
import xmpp.IQType;


/**
	Manages discovery of services from XMPP entities.<br>
	Two kinds of information can be discovered:<br>
	(1) the identity and capabilities of an entity, including the protocols and features it supports,<br>
	(2) the items associated with an entity, such as the list of rooms hosted at a multi-user chat service.<br>
	
	<a href="http://www.xmpp.org/extensions/xep-0030.html">XEP 30 - ServiceDiscovery</a>
*/
class ServiceDiscovery {
	
	public dynamic function onInfo( e : IQResult<Stream,xmpp.disco.Info> ) : Void;
	public dynamic function onItems( i : IQResult<Stream,xmpp.disco.Items> ) : Void;
	public dynamic function onError( e : jabber.event.XMPPErrorEvent<Stream> ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	
	var iq_info : IQ;
	var iq_item : IQ;
	
	
	public function new( stream : Stream ) {
		
		this.stream = stream;
		
		iq_info = new IQ();
		iq_info.ext = new xmpp.disco.Info();
		iq_item = new IQ();
		iq_item.ext = new xmpp.disco.Items();
	}
	
	
	/**
		Queries entity for information.
	*/
	public function discoverInfo( jid : String ) {
		iq_info.to = jid;
		stream.sendIQ( iq_info, handleInfoRequest );
	}
	
	/**
		Queries entity for items.
	*/
	public function discoverItems( jid : String ) {
		iq_item.to = jid;
		stream.sendIQ( iq_item, handleItemRequest, false, new jabber.core.PacketTimeout( [timeoutHandler],2 ) );
	}
	
	
	function timeoutHandler( collector ) {
		// TODO trace("timeoutHandlertimeoutHandlertimeoutHandlertimeoutHandler");
		stream.collectors.remove( collector );
	}
	
	
	function handleInfoRequest( iq : IQ ) {
		switch( iq.type ) {
			case result :
				var l = xmpp.disco.Info.parse( iq.ext.toXml() );
				var e = new IQResult<jabber.Stream,xmpp.disco.Info>( stream, iq, l );
				onInfo( e );
			case error :
				onError( new jabber.event.XMPPErrorEvent<jabber.Stream>( stream, iq ) );
			default : //#
		}
	}
	
	function handleItemRequest( iq : IQ ) {
		switch( iq.type ) {
			case result :
				var l = xmpp.disco.Items.parse( iq.ext.toXml() );
				var e = new IQResult<jabber.Stream,xmpp.disco.Items>( stream, iq, l );
				onItems( e );
			case error :
				onError( new jabber.event.XMPPErrorEvent<jabber.Stream>( stream, iq ) );
			default: //#
		}
	}
	
}
