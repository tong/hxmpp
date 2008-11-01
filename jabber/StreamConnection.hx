package jabber;


typedef StreamConnection = {
	
	// TODO check filters,interceptors
	
	var onConnect : Void->Void;
	var onDisconnect : Void->Void;
	var onData : String->Void;
	var onError : Dynamic->Void;
	
	var connected(default,null) : Bool;
	
	function connect() : Void;
	function disconnect() : Bool;
	function send( data : String ) : Bool;
	function read( ?yes : Bool ) : Bool;
	
}
