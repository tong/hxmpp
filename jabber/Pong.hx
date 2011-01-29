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
	<a href="http://www.xmpp.org/extensions/xep-0199.html">XEP 199 - XMPP Ping</a><br/>
	Listens for incoming ping messages and automaticly responds with a pong.
*/
class Pong {
	
	/** Informational callback, informing that a ping has been recieved and responded to. */
	public dynamic function onPong( jid : String ) : Void;

	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		if( !stream.features.add( xmpp.Ping.XMLNS ) )
			throw new jabber.error.Error( "Ping listener already added" );
		this.stream = stream;
		stream.collect( [ cast new xmpp.filter.IQFilter( xmpp.Ping.XMLNS, xmpp.IQType.get ) ], handlePing, true );
	}
	
	function handlePing( iq : xmpp.IQ ) {
		var r = xmpp.IQ.createResult( iq );
		r.properties.push( xmpp.Ping.xml );
		stream.sendData( r.toString() );
		onPong( iq.from );
	}
		
}
