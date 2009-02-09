package jabber;

import jabber.core.PacketCollector;
import xmpp.filter.IQFilter;


/**
	Listens/Answers incoming service discovery requests.
*/
class ServiceDiscoveryListener {
	
	public static var defaultIdentity = { category : "client", name : "hxmpp", type : "pc" };
	
	public var stream(default,null) : Stream;
	public var identity : xmpp.disco.Identity;
	
	
	public function new( stream : Stream,  ?identity : xmpp.disco.Identity ) {
		
		if( !stream.features.add( xmpp.disco.Info.XMLNS ) ||
			!stream.features.add( xmpp.disco.Items.XMLNS ) ) {
			throw "ServiceDiscovery listener feature already added";
		}
		
		this.stream = stream;
		this.identity = ( identity != null ) ? identity : defaultIdentity;
	
		stream.addCollector( new PacketCollector( [ cast new xmpp.filter.IQFilter( xmpp.disco.Info.XMLNS, null, xmpp.IQType.get ) ], handleInfoQuery, true ) );
		stream.addCollector( new PacketCollector( [ cast new xmpp.filter.IQFilter( xmpp.disco.Items.XMLNS, null, xmpp.IQType.get ) ], handleItemsQuery, true ) );
	}
	
	
	//public function dispose() {
	
	/**
	public function publishItems( jid : String ) {
		//TODO
	}
	*/
	
	
	function handleInfoQuery( iq : xmpp.IQ ) {
		var r = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from, stream.jid.toString() );
		r.ext = new xmpp.disco.Info( [identity], Lambda.array( stream.features ) );
		stream.sendData( r.toString() );
	}
	
	function handleItemsQuery( iq : xmpp.IQ ) {
		trace("händleItemsQuery");
		//TODO
		/*
	<iq type="error" to="account@disktree/desktop" id="info1" >
	  	<query xmlns="http://jabber.org/protocol/disco#items"/>
		<error type="cancel" >
			<feature-not-implemented xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/>
		</error>
	</iq>
	*/
	}
	
}
