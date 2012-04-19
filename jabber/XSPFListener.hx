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
	Listens for incoming XSPF playlist requests
*/
class XSPFListener {
	
	public dynamic function onRequest( jid : String ) : xspf.Playlist { return null; }
	
	public var stream(default,null) : Stream;
	
	var c : jabber.stream.PacketCollector;
	
	public function new( stream : Stream ) {
		if( !stream.features.add( xmpp.XSPF.XMLNS ) )
			throw "xspf listener already added" ;
		this.stream = stream;
		c = stream.collect( [new xmpp.filter.IQFilter( xmpp.XSPF.XMLNS, xmpp.IQType.get, "query" )], handleRequest, true );
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		var r = xmpp.IQ.createResult( iq );
		var pl = onRequest( iq.from );
		if( pl != null ) {
			var x = xmpp.XSPF.emptyXml();
			x.addChild( pl.toXml() );
			r.properties.push( x );
		}
		stream.sendPacket( r );
	}
	
}
