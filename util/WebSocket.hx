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

#if js

extern class WebSocket {
	
	static inline var CONNECTING = 0;
	static inline var OPEN = 1;
	static inline var CLOSING = 2;
	static inline var CLOSED = 3;
	
	var readyState(default,never) : Int;
	var bufferedAmount(default,never) : Int;
	
	dynamic function onopen() : Void;
	dynamic function onmessage(e:{data:String}) : Void; //correct?
	dynamic function onclose() : Void;
	dynamic function onerror() : Void;
	
	var url(default,never) : String;
	var protocol(default,never) : String;
	
	function new( url : String, ?protocol : Dynamic ) : Void;
	
	function send( data : String ) : Bool;
	function close() : Void;
}


#elseif flash

import flash.external.ExternalInterface;

/**
	Add hxmpp/util/flash_websocket.js to your website to use this.
*/
class WebSocket {
	
	public dynamic function onopen() {}
	public dynamic function onmessage(e:{data:String}) {} //correct?
	public dynamic function onclose() {}
	public dynamic function onerror() {}
	
	public var url(default,null) : String;
	
	public function new( url : String ) {
		if( !ExternalInterface.available )
			throw "external interface not available";
		this.url = url;
		ExternalInterface.addCallback( "init", init );
		var me = this;
		ExternalInterface.addCallback( "onopen", function(){me.onopen();} );
		ExternalInterface.addCallback( "onmessage", function(e){me.onmessage(e);} );
		ExternalInterface.addCallback( "onclose", function(){me.onclose();} );
		ExternalInterface.addCallback( "onerror", function(){me.onerror();} );
		ExternalInterface.call( "init", "flash" );
	}
	
	function init() : Bool {
		ExternalInterface.addCallback( "start", start );
		return true;
	}
	
	function start() {
		ExternalInterface.call( "initWebSocket", url );
	}
	
	public function send( data : String ) : Bool {
		ExternalInterface.call( "write", data );
		return true;
	}
	
	public function close() : Void {
		ExternalInterface.call( "close" );
	}
	
}

#end
