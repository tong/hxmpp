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
package jabber.file;

/**
	A listener for incoming in-band file transfers.
*/
class IBListener {
	
	/** Callback for incoming file transfer requests */
	public var onRequest : IBReciever->Void;
	public var stream(default,null) : jabber.Stream;
	
	public function new( stream : jabber.Stream ) {
		this.stream = stream;
		// collect requests
		var f : xmpp.PacketFilter = new xmpp.filter.IQFilter( xmpp.file.IB.XMLNS, "open", xmpp.IQType.set );
		stream.addCollector( new jabber.stream.PacketCollector( [f], handleRequest, true ) );
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		var r = new IBReciever( stream );
		if( r.handleRequest( iq ) )
			onRequest( r );
	}
	
}
