package jabber;



/**
	Abstract connection for jabber streams.
*/
class StreamConnection implements IStreamConnection {
	
	public var connected(default,null) 	: Bool;
	public var onConnect 	: Void->Void;
	public var onDisconnect : Void->Void;
	public var onData 		: String->Void;
	
	
	function new() {
		connected = false;
	}
	
	
	public function connect() {  throw "Abstract method"; }
	public function disconnect() { throw "Abstract method"; }
	public function read( ?active : Bool ) : Bool{ return throw "Abstract method"; }
	public function send( data : String ) : Bool { return throw "Abstract method";}
	
	//#if flash
	//public var crossdomain : String;
	//#end
}
