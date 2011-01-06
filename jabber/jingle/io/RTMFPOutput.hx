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

import flash.events.NetStatusEvent;
import flash.net.NetStream;

class RTMFPOutput extends RTMFPTransport {
	
	public function new( url : String ) {
		super( url );
	}
	
	public function publish( pubid : String ) {
		ns.publish( pubid );
	}
	
	public override function toXml() : Xml {
		var x = Xml.createElement( "candidate" );
		//x.set( "name", name );
		x.set( "id", nc.nearID );
		/*
		var r = ~/(rtmfp:\/\/)([A-Z0-9.-]+\.[A-Z][A-Z][A-Z]?)(\/([A-Z0-9\-]+))?/i;
		if( !r.match( url ) ) {
			//TODO
			trace("IIIIIIIIIINVAID RTMFP URL");	
			return null;
		}
		x.set( "url", r.matched(1)+r.matched(2) );
		*/
		x.set( "url", url );
		return x;
	}
	
	override function netConnectionHandler( e : NetStatusEvent ) {
		trace(e.info.code);
		switch( e.info.code ) {
		case "NetConnection.Connect.Success" :
			ns = new NetStream( nc, NetStream.DIRECT_CONNECTIONS );
			ns.addEventListener( NetStatusEvent.NET_STATUS, netStreamHandler );
			__onConnect();
		//case "NetStream.Connect.Success" :
			//__onInit();
		}
	}
	
}
