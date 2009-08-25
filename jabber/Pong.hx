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
	Listens for incoming ping messages and automaticly responds with a pong.
	<a href="http://www.xmpp.org/extensions/xep-0199.html">XEP 199 - XMPP Ping</a>
*/
class Pong {
	
	/**
		Informational event that a ping has been recieved and responded to.
	*/
	public dynamic function onPong( entity : String ) : Void;

	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		if( !stream.features.add( xmpp.Ping.XMLNS ) )
			throw "Ping feature already added";
		this.stream = stream;
		stream.addCollector( new jabber.stream.PacketCollector( [ cast new xmpp.filter.IQFilter( xmpp.Ping.XMLNS, null, xmpp.IQType.get ) ], handlePing, true ) );
	}
	
	function handlePing( iq : xmpp.IQ ) {
		var r = xmpp.IQ.createResult( iq );
		r.x = new xmpp.Ping();
		stream.sendData( r.toString() );
		onPong( iq.from );
	}
		
}
