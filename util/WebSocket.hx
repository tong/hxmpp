
extern class WebSocket {
	
	static inline var CONNECTING = 0;
	static inline var OPEN = 1;
	static inline var CLOSED = 2;
	
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
