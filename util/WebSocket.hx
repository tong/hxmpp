/*
 * Copyright (c) 2012, tong, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
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
	var extensions(default,never) : String;
	var protocol(default,never) : String;
	var binaryType : String;
	
	function new( url : String, ?protocol : Dynamic ) : Void;
	
	@:overload(function( data : Blob ):Void{})
	@:overload(function( data : ArrayBuffer ):Void{})
	function send( data : String ) : Bool;
	
	function close( ?code : Int, ?reason : String ) : Void;
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
