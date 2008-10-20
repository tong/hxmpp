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
	Extension to discover infos and items of an xmpp entity.
	
	<a href="http://www.xmpp.org/extensions/xep-0030.html">XEP 30 - ServiceDiscovery</a>
	
	Manages discovery of services from XMPP entities.<br>
	Two kinds of information can be discovered:<br>
	(1) the identity and capabilities of an entity, including the protocols and features it supports,<br>
	(2) the items associated with an entity, such as the list of rooms hosted at a multi-user chat service.<br>
	
*/
class ServiceDiscovery {
	
	public static var defaultIdentityName = "hxmpp";
	public static var defaultIdentityType = "pc";

	public dynamic function onInfo( e : DiscoInfo ) {}
	public dynamic function onItem( e : DiscoItem ) {}
	
	public var identityName : String;
	public var identityType : String;
	public var stream(default,null) : StreamBase;
	public var listener(default,null) : ServiceDiscoveryListener;
	
	var iq_info : IQ;
	var iq_item : IQ;
	
	
	public function new( stream : StreamBase, ?identityName : String, ?identityType : String ) {
		
		this.stream = stream;
		this.identityName = ( identityName != null ) ? identityName : defaultIdentityName;
		this.identityType = ( identityType != null ) ? identityType : defaultIdentityType;
		
		listener =  new ServiceDiscoveryListener( stream );
		listener.active = true;
		
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


/**
	Listens for incoming service discovery requests.
*/
private class ServiceDiscoveryListener {
	
	public var stream(default,null) : StreamBase;
	public var active(default,setActive) : Bool;
	
	var collector_info : PacketCollector;
	var collector_item : PacketCollector;
	
	
	public function new( stream : StreamBase ) {
		
		this.stream = stream;
		
		collector_info = new PacketCollector( [ cast new IQFilter( xmpp.disco.Info.XMLNS, null, IQType.get ) ], handleInfoQuery, true );
		collector_item = new PacketCollector( [ cast new IQFilter( xmpp.disco.Items.XMLNS, null, IQType.get ) ], handleItemQuery, true );
	}
	
	
	function setActive( a : Bool ) : Bool {
		if( a == active ) return a;
		Reflect.setField( this, "active", a );
		if( a ) {
			stream.collectors.add( collector_info );
			stream.collectors.add( collector_item );
		} else {
			stream.collectors.remove( collector_info );
			stream.collectors.remove( collector_item );
		}
		return a;
	}
	
	
	function handleInfoQuery( iq : IQ ) {
		trace("handleInfoQuery");
	}
	
	function handleItemQuery( iq : IQ ) {
		trace("handleItemQuery");
	}
	
}
