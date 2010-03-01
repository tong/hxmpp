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
package jabber.jingle;

import jabber.stream.PacketCollector;

/**
	Listens for incoming jingle-RTMP session requests.
*/
class RTMPListener {
	
	public var stream(default,null) : jabber.Stream;
	public var handler(default,setHandler) : RTMPResponder->Void;
	
	var c : PacketCollector;
	
	public function new( stream : jabber.Stream, handler : RTMPResponder->Void ) {
		if( !stream.features.add( xmpp.jingle.RTMP.XMLNS ) )
			throw "RTMP listener already added";
		this.stream = stream;
		this.handler = handler;
	}
	
	function setHandler( h : RTMPResponder->Void ) : RTMPResponder->Void {
		if( c != null ) {
			stream.removeCollector( c );
			c = null;
		}
		if( h != null )
			c = stream.collect( [cast new xmpp.filter.IQFilter( xmpp.Jingle.XMLNS, "jingle", xmpp.IQType.set ),
								 cast new xmpp.filter.JingleFilter( xmpp.jingle.RTMP.XMLNS ) ], handleRequest, true );
		return handler = h;
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		if( handler == null )
			return;
		var r = new jabber.jingle.RTMPResponder( stream );
		if( r.handleRequest( iq ) )
			handler( r );
	}
	
}
