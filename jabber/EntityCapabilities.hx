/*
 * Copyright (c) 2012, disktree.net
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

import xmpp.PresenceType;

/**
	Extension for broadcasting and dynamically discovering client, device, or generic entity capabilities.

	XEP-0085: Entity Capabilities: http://xmpp.org/extensions/xep-0115.html
*/
class EntityCapabilities {

	/** Callback to application for checking if caps already exist (in cache) */
	public dynamic function onCaps( jid : String, caps : xmpp.Caps, cb : Bool->Void ) {}
	
	/** Fired when a new entity capability got discovered */
	public dynamic function onInfo( jid : String, info : xmpp.disco.Info, ?ver : String ) {}
	
	public dynamic function onError( e : jabber.XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	/**
		A URI that uniquely identifies a software application,
		typically a URL at the website of the project or company that produces the software
	*/
	public var node(default,null) : String;
	
	//public var dataform : xmpp.DataForm;
	
	/** My own verification string */
	public var ver(default,null) : String;
	
	var collector : PacketCollector;
	var x : Xml;
	
	public function new( stream : Stream, node : String, identities : Array<xmpp.disco.Identity>,
						 ?ext : String ) {
		
		if( !stream.features.has( xmpp.disco.Info.XMLNS ) )
			throw "disco-info is a required stream feature for entity capabilities";
		
		this.stream = stream;
		this.node = node;
		
		createVerificationString( identities, stream.features );
		
		x = new xmpp.Caps( "sha-1", node, ver ).toXml();
		
		//ver = xmpp.Caps.createVerfificationString( identities, stream.features, dataform );
		stream.addInterceptor( this );
		var filters : Array<xmpp.PacketFilter> = [new xmpp.filter.PacketTypeFilter( xmpp.PacketType.presence ), new xmpp.filter.PacketPropertyFilter( xmpp.Caps.XMLNS, "c" )];
		collector = stream.collect( filters, handlePresence, true );
	}
	
	/**
		Create/Recreate the verification string
		Call if your stream changes features
	*/
	public function createVerificationString( identities : Array<xmpp.disco.Identity>, features : Iterable<String>, ?dataform : xmpp.DataForm  ) {
		ver = xmpp.Caps.createVerfificationString( identities, features, dataform );
	}
	
	public function interceptPacket( p : xmpp.Packet ) : xmpp.Packet {
		if( p._type != xmpp.PacketType.presence )
			return p;
			
		//TODO do not send caps with every presence (not to groupchats fe)
		if( cast( p, xmpp.Presence ).type == subscribe )
			return p;
			
		//trace("INTERCEPT CAPS "+p.to+" : "+JIDUtil.isValid( p.to )  );
		//if( p.to != null && !JIDUtil.isValid( p.to ) )
		//	return p;
		
		p.properties.push( x );
		return p;
	}
	
	public function dispose() {
		stream.removeInterceptor( this );
		stream.removeCollector( collector );
	}
	
	function handlePresence( p : xmpp.Presence ) {
		var c = xmpp.Caps.fromPresence( p );
		onCaps( p.from, c, function(h){
			if( !h ) requestDiscoInfo( p.from, c.node+"#"+c.ver );
		});
		//if( !onCaps( p.from, c ) )
		//	requestDiscoInfo( p.from, c.node+"#"+c.ver );	
	}
	
	function handleInfoResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			var i = xmpp.disco.Info.parse( iq.x.toXml() );
			var ver : String = null;
			if( i.node != null ) {
				var j = i.node.indexOf( "#" );
				if( j != -1 )
					ver = i.node.substr( j+1 );
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
