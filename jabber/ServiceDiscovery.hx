package jabber;

import jabber.core.StreamBase;
import jabber.core.PacketCollector;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.filter.IQFilter;

/*
class DiscoEvent<T> extends T {
	public var stream : StreamBase;
	public var from : String;
	//public function new() {	super(); }
}*/
//typedef DiscoInfo = jabber.DiscoEvent<xmpp.disco.Info>;
//typedef DiscoItems = jabber.DiscoEvent<xmpp.disco.Items>;


private class DiscoInfo extends xmpp.disco.Info {
	public var stream : StreamBase;
	public var from : String;
	//public var error : xmpp.Error;
	//public function new() {	super(); }
}

private class DiscoItems extends xmpp.disco.Items {
	public var stream : StreamBase;
	public var from : String;
	//public var error : xmpp.Error;
	//public function new() { super(); }
}


/**
	Manages discovery of services from XMPP entities.<br>
	Two kinds of information can be discovered:<br>
	(1) the identity and capabilities of an entity, including the protocols and features it supports,<br>
	(2) the items associated with an entity, such as the list of rooms hosted at a multi-user chat service.<br>
	
	<a href="http://www.xmpp.org/extensions/xep-0030.html">XEP 30 - ServiceDiscovery</a>
*/
class ServiceDiscovery {
	
	public dynamic function onInfo( e : DiscoInfo ) {}
	public dynamic function onItems( e : DiscoItems ) {}
	public dynamic function onError( error : jabber.XMPPError ) {}
	
	public var stream(default,null) : StreamBase;
	
	var iq_info : IQ;
	var iq_item : IQ;
	
	
	public function new( stream : StreamBase ) {
		
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

	/**
	*/
	public function publishItems( id : String, items : xmpp.disco.Items ) {
		//TODO
	}
	
	
	function timeoutHandler( collector ) {
		// TODO
		stream.collectors.remove( collector );
		//trace("timeoutHandlertimeoutHandlertimeoutHandlertimeoutHandler");
	}
	
	
	function handleInfoRequest( iq : IQ ) {
		switch( iq.type ) {
			case result :
				var i : DiscoInfo = cast xmpp.disco.Info.parse( iq.ext.toXml() );
				i.from = iq.from;
				i.stream = stream;
				onInfo( i );
		//	case error :
		//		var err = xmpp.Error.parsePacket( iq ); 
		//		trace( err );
				//TODO
			default: //#
		}
	}
	
	function handleItemRequest( iq : IQ ) {
		switch( iq.type ) {
			case result :
				var i : DiscoItems = cast xmpp.disco.Items.parse( iq.ext.toXml() );
				i.from = iq.from;
				i.stream = stream;
				onItems( i );
				
			case error :
				//TODO
			default: //#
		}
	}
	
	function handleItemPublish( iq : IQ ) {
		//TODO
	}
	
}
