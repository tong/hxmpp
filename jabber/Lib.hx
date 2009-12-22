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

#if JABBER_SOCKETBRIDGE
import jabber.SocketConnection;
#end

class Lib {
	
	#if JABBER_DEBUG
	public static inline var VERSION = "0.4";
	#end
	
	#if JABBER_SOCKETBRIDGE
	
	public static var defaultSocketBridgeID = "f9bridge";
	
	static function initSocketBridge( ?id : String ) {
		if( id == null ) id = defaultSocketBridgeID;
		jabber.SocketBridgeConnection.initDelayed( id, initialized );
	}
	static function initialized() {
		#if JABBER_DEBUG
		trace( "Socket bridge hopefuly initialized" );
		#end
	}
	
	#end
	
}
