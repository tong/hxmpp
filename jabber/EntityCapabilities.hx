/*
 * Copyright (c) 2012, tong, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber;

/**
	<a href="http://xmpp.org/extensions/xep-0115.html">XEP-0085: Entity Capabilities</a><br/>
	Extension for broadcasting and dynamically discovering client, device, or generic entity capabilities.
*/
class EntityCapabilities {
	
	//public dynamic function onCaps( jid : String, caps : xmpp.Caps ) {}
	/** Fired if a new entity capability got discovered */
	public dynamic function onInfo( jid : String, info : xmpp.disco.Info, ?ver : String ) {}
	public dynamic function onError( e : jabber.XMPPError ) {}
	
	public var stream(default,null) : Stream;
	public var cached(default,null) : Hash<xmpp.disco.Info>;
	public var node : String;
	public var ext : String;
	public var identities : Array<xmpp.disco.Identity>;
	public var dataform : xmpp.DataForm;//TODO
	public var ver(default,null) : String;
	
	var collector : jabber.stream.PacketCollector;
	
	public function new( stream : Stream, node : String, identities : Array<xmpp.disco.Identity>,
						 ?ext : String ) {
		if( !stream.features.has( xmpp.disco.Info.XMLNS ) )
			throw "Disco-info is a required stream feature for entity capabilities";
		this.stream = stream;
		this.node = node;
		this.identities = identities;
		this.ext = ext;
		cached = new Hash();
		collector = stream.collect( [new xmpp.filter.PacketTypeFilter( xmpp.PacketType.presence ),
						 			 new xmpp.filter.PacketPropertyFilter( xmpp.Caps.XMLNS, "c" )],
									 handlePresence, true );
		stream.addInterceptor( this );
	}
	
	public function interceptPacket( p : xmpp.Packet ) : xmpp.Packet {
		if( !Std.is( p, xmpp.Presence ) )
			return p;
		//TODO cache it (?)
		ver = xmpp.Caps.createVerfificationString( identities, stream.features, dataform );
		p.properties.push( new xmpp.Caps( "sha-1", node, ver, ext ).toXml() );
		return p;
	}
	
	public function dispose() {
		stream.removeInterceptor( this );
		stream.removeCollector( collector );
		cached = new Hash();
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
					cached.set( ver, i );
				}
			}
			onInfo( iq.from, i, ver );
		case error :
			onError( new jabber.XMPPError( iq ) );
		default :
		}
	}
	
	function requestDiscoInfo( jid : String, ?node : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.get, null, jid );
		iq.x = new xmpp.disco.Info( null, null, node );
		stream.sendIQ( iq, handleInfoResponse );
	}
	
}
