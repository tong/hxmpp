package jabber;

import jabber.core.StreamBase;
import jabber.core.PacketCollector;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.filter.IQFilter;


private class DiscoInfo extends xmpp.disco.Info {
	public var stream : StreamBase;
	public var from : String;
	public function new() {	super(); }
}

private class DiscoItem extends xmpp.disco.Items {
	public var stream : StreamBase;
	public var from : String;
	public function new() { super(); }
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
	public dynamic function onItem( e : DiscoItem ) {}
	
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
		stream.sendIQ( iq_info, handleInfo );
	}
	
	/**
	*/
	public function discoverItems( jid : String ) {
		iq_item.to = jid;
		stream.sendIQ( iq_item, handleItem );
	}
	
		//TODO
	function handleInfo( iq : IQ ) {
		switch( iq.type ) {
			case result :
				var i : DiscoInfo = cast xmpp.disco.Info.parse( iq.ext.toXml() );
				i.from = iq.from;
				i.stream = stream;
				onInfo( i );
			case error :
				//TODO
			default: //#
				//TODO
		}
	}
	
		//TODO
	function handleItem( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result :
				var i : DiscoItem = cast xmpp.disco.Items.parse( iq.ext.toXml() );
				i.from = iq.from;
				i.stream = stream;
				onItem( i );
			case error :
				//TODO
			default: //#
				//TODO
		}
	}
	
}
