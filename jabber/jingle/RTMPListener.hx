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

/**
	Listens for incoming jingle session requests.
*/
class RTMPListener {
	
	/** Callback for RTMP session requests */
	public var handler : RTMPResponder->Void;
	public var stream(default,null) : jabber.Stream;
		
	public function new( stream : jabber.Stream, handler : RTMPResponder->Void ) {
		if( !stream.features.add( xmpp.jingle.RTMP.XMLNS ) )
			throw "RTMP session listener already added";
		stream.features.add( xmpp.Jingle.XMLNS );
		this.stream = stream;
		this.handler = handler;
		// collect RTMP session requests
		stream.addCollector( new jabber.stream.PacketCollector( [cast new xmpp.filter.JingleFilter( xmpp.jingle.RTMP.XMLNS ) ], handleRequest, true ) );
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		var r = new jabber.jingle.RTMPResponder( stream );
		if( r.handleRequest( iq ) )
			handler( r );
		else {
			trace("request not handled");
		}
	}
	
}
