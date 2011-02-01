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

class RTMFPInput extends RTMFPTransport {
	
	public var pubid(default,null) : String;
	
	public function new( url : String, id : String, pubid : String ) {
		super( url );
		this.id = id;
		this.pubid = pubid;
	}
	
	public override function toXml() : Xml {
		//TODO out of any (non-existing) spec
		var x = Xml.createElement( "candidate" );
		x.set( "id", id );
		return x;
	}
	
	override function netConnectionHandler( e : NetStatusEvent ) {
		#if JABBER_DEBUG trace( e.info.code ); #end
		switch( e.info.code ) {
		case "NetConnection.Connect.Failed" :
			__onFail( e.info.code );
		case "NetConnection.Connect.Success" :
			__onConnect();
		case "NetConnection.Connect.Closed" :
			__onDisconnect();
		}
	}

	public static function ofCandidate( x : Xml ) : RTMFPInput {
		//TODO maybe url splitting here
		return new RTMFPInput( x.get( "url" ), x.get( "id" ), x.get( "pubid" ) );
	}
	
}
