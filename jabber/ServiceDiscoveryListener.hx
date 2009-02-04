package jabber;

import jabber.core.PacketCollector;
import xmpp.filter.IQFilter;

//TODO join with ServiceDiscovery

/**
	Listens/Answers incoming service discovery requests.
*/
class ServiceDiscoveryListener {
	
	public static var defaultIdentity = { category : "client", name : "hxmpp", type : "pc" };
	
	public var stream(default,null) : Stream;
	public var identity : xmpp.disco.Identity;
	
	
	public function new( stream : Stream,  ?identity : xmpp.disco.Identity ) {
		
		if( !stream.features.add( xmpp.disco.Info.XMLNS ) /*||
			!stream.features.add( xmpp.disco.Items.XMLNS )*/ ) {
			throw "ServiceDiscovery listener already added";
		}
		
		this.stream = stream;
		this.identity = ( identity != null ) ? identity : defaultIdentity;
	
		var c_info = new PacketCollector( [ cast new xmpp.filter.IQFilter( xmpp.disco.Info.XMLNS, null, xmpp.IQType.get ) ], handleInfoQuery, true );
		stream.addCollector( c_info );
		
		//.TODO items
	}
	
	
	//public function dispose() {
	
	
	function handleInfoQuery( iq : xmpp.IQ ) {
		var r = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from, stream.jid.toString() );
		r.ext = new xmpp.disco.Info( [identity], Lambda.array( stream.features ) );
		stream.sendData( r.toString() );
	}
	
	//TODO
	/*
	function handleItemsQuery( iq : xmpp.IQ ) {
		trace("handleItemsQuery");
	<iq type="error" to="account@disktree/desktop" id="info1" >
	  	<query xmlns="http://jabber.org/protocol/disco#items"/>
		<error type="cancel" >
			<feature-not-implemented xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/>
		</error>
	</iq>
	}
	*/
	
}


//TODO
/**
	Listens/Answers incoming service discovery requests.
class ServiceDiscoveryListener {
	
	public static var defaultIdentity = { category : "client", name : "hxmpp", type : "pc" };
	
	public var stream(default,null) : Stream;
	//TODO public var node(default,null) : String;
	public var listen(default,setListening) : Bool;
	public var identity : xmpp.disco.Identity;
	
	var col_info : PacketCollector;
	var col_item : PacketCollector;
	var info_result : IQ;
	var info_result_ext : xmpp.disco.Info;
//	var item_result : IQ;
//	var item_result_ext : xmpp.disco.Item;
	
	
	public function new( stream : Stream,  ?identity : xmpp.disco.Identity, listening : Bool = true ) {
		
		this.stream = stream;
		this.identity = if( identity != null ) identity else defaultIdentity;
		
		info_result = new IQ( IQType.result );
		info_result_ext = new xmpp.disco.Info();
		info_result_ext.identities = [ identity ];
		info_result.ext = info_result_ext;
		
//		item_result = new IQ( IQType.result );
//		item_result.ext = item_result;
		
		col_info = new PacketCollector( [ cast new IQFilter( xmpp.disco.Info.XMLNS, null, IQType.get ) ], handleInfoQuery, true );
//		col_item = new PacketCollector( [ cast new IQFilter( xmpp.disco.Items.XMLNS, null, IQType.get ) ], handleItemQuery, true );
		
		setListening( listening );
	}
	
	
	function setListening( l : Bool ) : Bool {
		if( l == listen ) return l;
		listen = l;
		if( l ) {
			stream.addCollector( col_info );
//			stream.collectors.add( col_item );
		} else {
			stream.removeCollector( col_info );
//			stream.collectors.remove( col_item );
		}
		return l;
	}
	
	
	function handleInfoQuery( iq : IQ ) {
		info_result.to = iq.from;
		info_result_ext.identities = [identity];
		info_result_ext.features = new Array();
		// TODO 
		for( f in stream.features ) {
			info_result_ext.features.push( f );
		}
		stream.sendIQ( info_result );
	}
	
	
	function handleItemQuery( iq : IQ ) {
		//TODO
	}
	
}

*/
