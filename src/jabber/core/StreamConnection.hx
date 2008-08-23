package jabber.core;


/**
	Abstract jabber stream io connection.
*/
class StreamConnection implements IStreamConnection {
	
	dynamic public function onConnect() : Void {}
	dynamic public function onDisconnect() : Void {}
	dynamic public function onData( data : String ) : Void {}

	public var connected(default,null) : Bool;
	
	
	function new() {
		connected = false;
	}
	
	
	public function connect() {  throw "Abstract method"; }
	public function disconnect() { throw "Abstract method"; }
	public function read( ?active : Bool = true ) : Bool{ return throw "Abstract method"; }
	public function send( data : String ) : Bool { return throw "Abstract method";}
	
}
