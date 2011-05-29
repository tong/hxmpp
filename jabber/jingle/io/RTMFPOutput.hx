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
import flash.net.NetStream;

@:require(flash10) class RTMFPOutput extends RTMFPTransport {
	
	/**
		Determines if the cirrus development key should get sent to the occupant in the candidate URL.
	*/
	public var send_cirrus_key : Bool;
	
	public function new( url : String,
						 send_cirrus_key : Bool = true ) {
		super( url );
		this.send_cirrus_key = send_cirrus_key;
	}
	
	public override function toXml() : Xml {
		var x = Xml.createElement( "candidate" );
		x.set( "id", id );
		if( send_cirrus_key ) x.set( "url", url );
		else {
			RTMFPTransport.EREG_URL.match( url );
			x.set( "url", RTMFPTransport.EREG_URL.matched(1)+
						  RTMFPTransport.EREG_URL.matched(2) );
		}
		return x;
	}
	
	override function netConnectionHandler( e : NetStatusEvent ) {
		#if JABBER_DEBUG trace( e.info.code, 'debug' ); #end
		switch( e.info.code ) {
		case "NetConnection.Connect.Success" :
			id = nc.nearID;
			__onConnect();
			return;
		//case "NetStream.Connect.Success" :
			//__onInit();
		//case "NetConnection.Connect.Failed" :
		//	trace("DFFFFFFFFFFFFFF");
		}
		super.netConnectionHandler( e );
	}
	
}

#end // flash
