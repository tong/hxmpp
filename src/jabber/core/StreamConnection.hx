package jabber.core;


/**
	Abstract jabber stream io connection.
*/
class StreamConnection implements IStreamConnection {
	
	public var connected(default,null) 	: Bool;
	public var onConnect 	: Void->Void;
	public var onDisconnect : Void->Void;
	public var onData 		: String->Void;
//	dynamic public function onConnect() : Void {}
//	dynamic public function onDisconnect() : Void {}
//	dynamic public function onData( data : String ) : Void {}
	//public var usedHost : String;
	
	function new() {
		connected = false;
	}
	
	
	public function connect() {  throw "Abstract method"; }
	public function disconnect() { throw "Abstract method"; }
	public function read( ?active : Bool = true ) : Bool{ return throw "Abstract method"; }
	public function send( data : String ) : Bool { return throw "Abstract method";}
	
	#if flash
	public var crossdomain : String;
	#end
	
}
