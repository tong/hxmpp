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

#if (js||flash)

/**
	WebSocket connection.
	http://tools.ietf.org/html/draft-moffitt-xmpp-over-websocket-00
	
	For flash you have to add hxmpp/util/flash_websocket.js glue code to your website
*/
class WebSocketConnection extends jabber.stream.Connection {
	
	public var url(default,null) : String;
	public var port(default,null) : Int;
	public var socket(default,null) : WebSocket;
	
	public function new( host : String = "localhost", port : Int = 5222, secure : Bool = false ) {
		super( host, secure );
		this.port = port;
		this.secure = secure;
		url = "ws"+(secure?"s":"")+"://"+host+":"+port; // unofficial specs do not support secure websocket connections (?)
	}
	
	public override function connect() {
		socket = new WebSocket( url );
		socket.onopen = onConnect;
		socket.onclose = onClose;
		socket.onerror = onError;
	}
	
	public override function disconnect() {
		socket.close();
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		socket.onmessage = yes ? onData : null;
		return true;
	}
	
	public override function write( t : String ) : Bool {
		socket.send( t );
		return true;
	}
	
	function onConnect() {
		connected = true;
		__onConnect();
	}
	
	function onClose() {
		connected = false;
		__onDisconnect(null);
	}
	
	function onError() {
		connected = false;
		__onDisconnect( "websocket error" ); // no error message?
	}
	
	function onData( m ) {
		__onString( m.data );
	}
	
	public static inline function isSupported() : Bool {
		#if js
		return untyped js.Lib.window.WebSocket != null;
		#elseif flash
		return flash.external.ExternalInterface.call( "hasWebSocketSupport" );
		#end
	}
	
}

#end //js||flash
