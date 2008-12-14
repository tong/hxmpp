package jabber;

import jabber.Stream;
import jabber.core.PacketCollector;
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
	
	//public dynamic function onInfo( e : IQResult<Stream,xmpp.disco.Info> ) : Void;
	//public dynamic function onInfo( d : ServiceDiscovery, e : xmpp.disco.Info ) : Void;
	//public dynamic function onItems( d : ServiceDiscovery, i : xmpp.disco.Items ) : Void;
	
	public dynamic function onInfo( d : ServiceDiscovery, node : String, data : xmpp.disco.Info ) : Void;
	public dynamic function onItems( d : ServiceDiscovery, node : String, data : xmpp.disco.Items ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	
	var iq_info : IQ;
	var iq_item : IQ;
	
	
	public function new( stream : Stream ) {
		
		this.stream = stream;
		
		iq_info = new IQ();
		iq_info.ext = new xmpp.disco.Info();
		iq_item = new IQ();
		//iq_item.ext = new xmpp.disco.Items();
	}
	
	
	/**
		Queries entity for information.
	*/
	public function discoverInfo( jid : String ) {
		iq_info.to = jid;
		stream.sendIQ( iq_info, handleInfoResult );
	}
	
	/**
		Queries entity for items.
	*/
	public function discoverItems( jid : String, ?node : String ) {
		//iq_item.to = jid;
		//iq_item.ext = new xmpp.disco.Items( node );
		var iq = new IQ( xmpp.IQType.get, null, jid );
		iq.ext = new xmpp.disco.Items( node );
		stream.sendIQ( iq, handleItemResult, false, new jabber.core.PacketTimeout( [timeoutHandler],2 ) );
	}
	
	
	function timeoutHandler( collector ) {
		// TODO trace("timeoutHandlertimeoutHandlertimeoutHandlertimeoutHandler");
		stream.collectors.remove( collector );
	}
	
	
	function handleInfoResult( iq : IQ ) {
		switch( iq.type ) {
			case result :
				var l = xmpp.disco.Info.parse( iq.ext.toXml() );
				onInfo( this, iq.from, l );
			case error :
				onError( new jabber.XMPPError( this, iq ) );
			default : //#
		}
	}
	
	function handleItemResult( iq : IQ ) {
		switch( iq.type ) {
			case result :
				var l = xmpp.disco.Items.parse( iq.ext.toXml() );
				onItems( this, iq.from, l );
			case error :
				onError( new jabber.XMPPError( this, iq ) );
			default: //#
		}
	}
	
}
