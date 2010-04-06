/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package jabber;

/**
	<a href="http://xmpp.org/extensions/xep-0115.html">XEP-0085: Entity Capabilities</a><br/>
	Extension for broadcasting and dynamically discovering client, device, or generic entity capabilities.<br/>
*/
class EntityCapabilities {
	
	//public dynamic function onCaps( jid : String, caps : xmpp.Caps ) : Void;
	/** Fired if a new (so far unknown) entity capability info got discovered */
	public dynamic function onInfo( jid : String, info : xmpp.disco.Info, ?ver : String ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	public var cached(default,null) : Hash<xmpp.disco.Info>;
	
	public var node : String;
	public var ext : String;
	public var identities : Array<xmpp.disco.Identity>;
	public var dataform : xmpp.DataForm;//TODO
	
	public var ver(default,null) : String;
	
	public function new( stream : Stream, node : String, identities : Array<xmpp.disco.Identity>,
						 ?ext : String ) {
		this.stream = stream;
		this.node = node;
		this.identities = identities;
		this.ext = ext;
		cached = new Hash();
		stream.collect( [cast new xmpp.filter.PacketTypeFilter( xmpp.PacketType.presence ),
						 cast new xmpp.filter.PacketPropertyFilter( xmpp.Caps.XMLNS, "c" )],
						handlePresence, true );
		stream.addInterceptor( this );
	}
	
	public function interceptPacket( p : xmpp.Packet ) : xmpp.Packet {
		if( Std.is( p, xmpp.Presence ) ) {
			//TODO don't create on every intercept.. overkill
			ver = xmpp.Caps.createVerfificationString( identities, stream.features, dataform );
			// TODO set own cap in cache
			//cached.set( ver, new xmpp.disco.Info( identities, Lambda.array( stream.features ) ) );
			var c = new xmpp.Caps( "sha-1", node, ver, ext );
			p.properties.push( c.toXml() );
		}
		return p;
	}
	
	function handlePresence( p : xmpp.Presence ) {
		var c = xmpp.Caps.fromPresence( p );
		if( c.hash != "sha-1" ) {
			requestDiscoInfo( p.from );
		} else {
			if( cached.exists( c.ver ) ) {
				onInfo( p.from, cached.get( c.ver ), c.ver );
			} else {
				cached.set( c.ver, null );
				requestDiscoInfo( p.from, c.node+"#"+c.ver );
			}
		}
	}
	
	function handleInfoResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			var i = xmpp.disco.Info.parse( iq.x.toXml() );
			var ver : String = null;
			if( i.node != null ) {
				var idx = i.node.indexOf( "#" );
				if( idx != -1 ) {
					ver = i.node.substr( idx+1 );
					cached.set( ver, i ); // cache recieved caps
				}
			}
			onInfo( iq.from, i, ver );
		case error :
			onError( new jabber.XMPPError( this, iq ) );
		default :
		}
	}
	
	function requestDiscoInfo( jid : String, ?node : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.get, null, jid );
		iq.x = new xmpp.disco.Info( null, null, node );
		stream.sendIQ( iq, handleInfoResponse );
	}
	
}
