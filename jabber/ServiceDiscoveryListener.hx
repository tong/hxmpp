package jabber;

import jabber.core.PacketCollector;
import xmpp.filter.IQFilter;


//typedef NodeInfoProvider = {
//}


/**
	Listens/Answers incoming service discovery requests.
*/
class ServiceDiscoveryListener {
	
	/* TODO (?) (no)
	static var listeners : List<{s:Stream,l:ServiceDiscoveryListener}>;
	public static function getListener( stream : Stream ) : ServiceDiscoveryListener {
		for( l in listeners ) {
			if( l.s == stream ) return l.l;
		}
		return null;
	}
	*/
	
	public static var defaultIdentity = { category : "client", name : "HXMPP", type : "pc" };
	
	public var stream(default,null) : Stream;
	public var identity(default,setIdentity): xmpp.disco.Identity;
	//TODO var nodeInfoProviders : List<TNodeInfoProvider>;
	
	
	public function new( stream : Stream,  ?identity : xmpp.disco.Identity ) {
		
		if( !stream.features.add( xmpp.disco.Info.XMLNS ) || !stream.features.add( xmpp.disco.Items.XMLNS ) ) {
			throw "ServiceDiscovery listener feature already added";
		}
		
		this.stream = stream;
		this.setIdentity( identity );
	
		stream.addCollector( new PacketCollector( [cast new xmpp.filter.IQFilter( xmpp.disco.Info.XMLNS, null, xmpp.IQType.get )], handleInfoQuery, true ) );
		stream.addCollector( new PacketCollector( [cast new xmpp.filter.IQFilter( xmpp.disco.Items.XMLNS, null, xmpp.IQType.get )], handleItemsQuery, true ) );
	}
	
	
	function setIdentity( id : xmpp.disco.Identity ) : xmpp.disco.Identity {
		return identity = ( id == null ) ? defaultIdentity :  id;
	}
	
	/*
	//TODO
		
	public function dispose() {
	}
	
	public function publishItems( jid : String ) {
	}
	*/
	
	
	function handleInfoQuery( iq : xmpp.IQ ) {
		var r = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from );
		r.ext = new xmpp.disco.Info( [identity], Lambda.array( stream.features ) );
		stream.sendData( r.toString() );
	}
	
	//TODO nodeInfoProviders
	// override me if you want
	function handleItemsQuery( iq : xmpp.IQ ) {
		// return error cancel
		var r = new xmpp.IQ( xmpp.IQType.error, iq.id, iq.from );
		r.errors.push( new xmpp.Error( xmpp.ErrorType.cancel, -1, xmpp.ErrorCondition.FEATURE_NOT_IMPLEMENTED ) );
		stream.sendPacket( r );
		/*
		var items = new xmpp.disco.Items();
		for( p in itemProvider.items ) {
			items.add( new xmpp.Item() );
		}
		*/
	}
	
}
