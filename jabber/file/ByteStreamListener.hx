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

class ByteStreamListener {
	
	public var handler : ByteStreamReciever->Void;
	
	public var stream(default,null) : jabber.Stream;
	
	public function new( stream : jabber.Stream, handler : ByteStreamReciever->Void ) {
		this.stream = stream;
		this.handler = handler;
		// collect file transfer requests
		var f : xmpp.PacketFilter = new xmpp.filter.IQFilter( xmpp.file.ByteStream.XMLNS, "query", xmpp.IQType.set );
		stream.addCollector( new jabber.stream.PacketCollector( [f], handleRequest, true ) );
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		//var bs = xmpp.file.ByteStream.parse( iq.x.toXml() );
		var me = this;
		
		var r = new ByteStreamReciever( stream );
		
		#if php
		if( r.handleRequest( iq ) ) {
			handler( r );
		}
		#else
		util.Delay.run( function(){
		if( r.handleRequest( iq ) )
			me.handler( r );
		}, 1000 );
		#end
	}
	
}
