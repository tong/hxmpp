package jabber;

import jabber.core.StreamBase;
import jabber.core.PacketCollector;
import jabber.event.IQResult;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.filter.IQFilter;

/*
class DiscoEvent<T> extends T {
	public var stream : StreamBase;
	public var from : String;
	//public function new() {	super(); }
}
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
	//public var info : xmpp.PacketInfo;
		
	public function new() {
		super();
	}
}
class DiscoInfoEvent extends jabber.event.XMPPPacketEvent {
	public var infos : xmpp.disco.Info; 
	public function new( s : StreamBase, iq : xmpp.Packet ) {
		super( s, iq );
		this.infos = xmpp.disco.Info.parse( iq.ext.toXml() );
	}
}
class DiscoInfoEvent extends xmpp.disco.Info {
	public var stream : StreamBase;
	public var from : String;
	public function new( stream : StreamBase, p : xmpp.Packet) {
		super();
		this.stream = stream;
		this.from = p.from;
	}
}
*/


/**
	Manages discovery of services from XMPP entities.<br>
	Two kinds of information can be discovered:<br>
	(1) the identity and capabilities of an entity, including the protocols and features it supports,<br>
	(2) the items associated with an entity, such as the list of rooms hosted at a multi-user chat service.<br>
	
	<a href="http://www.xmpp.org/extensions/xep-0030.html">XEP 30 - ServiceDiscovery</a>
*/
class ServiceDiscovery {
	
	public dynamic function onInfo( e : IQResult<xmpp.disco.Info> ) {}
	public dynamic function onItems( i : IQResult<xmpp.disco.Items> ) {}
	public dynamic function onError( e : jabber.event.XMPPErrorEvent ) {}
	
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
		//trace("timeoutHandlertimeoutHandlertimeoutHandlertimeoutHandler");
		stream.collectors.remove( collector );
	}
	
	
	function handleInfoRequest( iq : IQ ) {
		switch( iq.type ) {
			case result :
				var l = xmpp.disco.Info.parse( iq.ext.toXml() );
				var e = new IQResult<xmpp.disco.Info>( stream, iq, l );
				onInfo( e );
			case error :
				onError( new jabber.event.XMPPErrorEvent( stream, iq ) );
			default : //#
		}
	}
	
	function handleItemRequest( iq : IQ ) {
		switch( iq.type ) {
			case result :
				var l = xmpp.disco.Items.parse( iq.ext.toXml() );
				var e = new IQResult<xmpp.disco.Items>( stream, iq, l );
				onItems( e );
			case error :
				onError( new jabber.event.XMPPErrorEvent( stream, iq ) );
			default: //#
		}
	}
	
	function handleItemPublish( iq : IQ ) {
		//TODO
	}
	
}
