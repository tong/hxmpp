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
package jabber.jingle.io;

#if flash

import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.NetStream;

class RTMFPTransport extends Transport {
	
	public var url(default,null) : String;
	public var ns(default,null) : NetStream;
	
	var nc : NetConnection;
	
	function new( url : String ) {
		super();
		this.url = url;
	}
	
	public override function connect() {
		nc = new NetConnection();
		nc.addEventListener( NetStatusEvent.NET_STATUS, netConnectionHandler );
		try nc.connect( url ) catch( e : Dynamic ) {
			__onFail( "Failed to connect to RTMFP service" );
		}
	}
	
	public override function close() {
		if( ns != null ) ns.close();
		if( nc != null && nc.connected ) nc.close();
	}
	
	function netConnectionHandler( e : NetStatusEvent ) {
		trace(e.info.code);
	}
	
	function netStreamHandler( e : NetStatusEvent ) {
		trace(e.info.code);
	}
	
}
#end // flash
