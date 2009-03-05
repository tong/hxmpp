package jabber;

import jabber.stream.PacketCollector;


/**
	Extension for broadcasting and dynamically discovering client, device, or generic entity capabilities.
	
	<a href="http://xmpp.org/extensions/xep-0115.html">XEP-0085: Entity Capabilities</a><br/>
*/
class EntityCapabilities {
	
	/** */
	public dynamic function onCaps( jid : String, caps : xmpp.Caps ) : Void;
	/** */
	public dynamic function onInfo( jid : String, info : xmpp.disco.Info, ?ver : String ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	/** Collected entity capabilities ( keys are the verfification strings ) */
	public var caps(default,null) : Hash<xmpp.disco.Info>; //TODO extended info ( dataform )
	public var stream(default,null) : Stream;
	public var node : String;
	public var ext : String;
	
	
	public function new( stream : Stream, node : String, ?ext : String ) {
		
		this.stream = stream;
		this.node = node;
		this.ext = ext;
		
		caps = new Hash();	
		stream.addCollector( new PacketCollector( [cast new xmpp.filter.PacketTypeFilter( xmpp.PacketType.presence ),
												   cast new xmpp.filter.PacketPropertyFilter( xmpp.Caps.XMLNS, "c" )],
												  handlePresence, true ) );
	}
	
	
	/**
		Publishes own capabilities.
	*/
	public function publish( identities : Iterable<xmpp.disco.Identity>, features : Iterable<String>,
							 ?dataform : xmpp.DataForm ) {
		var p = new xmpp.Presence();
		var c = new xmpp.Caps( "sha-1", node, xmpp.Caps.createVerfificationString( identities, features, dataform ), ext );
		p.properties.push( c.toXml() );
		stream.sendData( p.toString() );			 
	}
	
	
	function handlePresence( p : xmpp.Presence ) {
		for( prop in p.properties ) {
			if( prop.nodeName == "c" ) {
				
				var _caps = xmpp.Caps.parse( prop );

				onCaps( p.from, _caps );
				
				if( _caps.hash != "sha-1" ) {
					requestDiscoInfo( p.from );
					return;
				}
				
				if( !caps.exists( _caps.ver ) ) {
					caps.set( _caps.ver, null );
					// discover infos
					requestDiscoInfo( p.from, _caps.node+"#"+_caps.ver );
				}
			}
		}
	}
	
	function handleInfoResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			var info = xmpp.disco.Info.parse( iq.ext.toXml() );
			var ver : String = null;
			if( info.node != null ) {
				var ver_index = info.node.indexOf("#");
				if( ver_index != -1 ) {
					ver = info.node.substr( ver_index+1 );
					// cache capabilities
					caps.set( ver, info );
				}
			}
			onInfo( iq.from, info, ver );
		case error :
			onError( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
	
	function requestDiscoInfo( from : String, ?node : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.get, null,from );
		iq.ext = new xmpp.disco.Info( null, null, node );
		stream.sendIQ( iq, handleInfoResponse );
	}
	
}
