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
	Listens for incoming ping messages and automaticly responds with a pong.<br/>
	<a href="http://www.xmpp.org/extensions/xep-0199.html">XEP 199 - XMPP Ping</a>
*/
class Pong {
	
	/** Informational callback on ping-pong */
	public dynamic function onPong( jid : String ) {}

	public var stream(default,null) : Stream;
	
	var c : jabber.stream.PacketCollector;
	
	public function new( stream : Stream ) {
		if( !stream.features.add( xmpp.Ping.XMLNS ) )
			throw "Ping listener already added";
		this.stream = stream;
		c = stream.collect( [ cast new xmpp.filter.IQFilter( xmpp.Ping.XMLNS, xmpp.IQType.get ) ], handlePing, true );
	}
	
	public function dispose() {
		if( c == null )
			return;
		stream.features.remove( xmpp.Ping.XMLNS );
		stream.removeCollector(c);
		c = null;
	}
	
	function handlePing( iq : xmpp.IQ ) {
		var r = xmpp.IQ.createResult( iq );
		r.properties.push( xmpp.Ping.xml );
		stream.sendData( r.toString() );
		onPong( iq.from );
	}
		
}
