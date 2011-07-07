
#if js

extern class WebSocket {
	
	static inline var CONNECTING = 0;
	static inline var OPEN = 1;
	static inline var CLOSING = 2;
	static inline var CLOSED = 3;
	
	var readyState(default,null) : Int;
	var bufferedAmount(default,null) : Int;
	
	dynamic function onopen() : Void;
	dynamic function onmessage(e:{data:String}) : Void; //correct?
	dynamic function onclose() : Void;
	dynamic function onerror() : Void;
	
	var url(default,null) : String;
	var protocol(default,null) : String;
	
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
