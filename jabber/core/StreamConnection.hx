package jabber.core;


private typedef DataFilter = {
	/**
		Filters incoming data before further processing ( fe: uncompression ).
	*/
	function filterData( data : String ) : String;
}


private typedef DataInterceptor = {
	/**
		Modifies raw data before sending ( fe: compression ).
	*/
	function interceptData( data : String ) : String;
}


//class StreamConnectionBase
class StreamConnection {
	
	public dynamic function onConnect() : Void;
	public dynamic function onDisconnect() : Void;
	public dynamic function onData( data : String ) : Void;
	public dynamic function onError( e : Dynamic ) : Void;
	
	public var connected(default,null) : Bool;
	public var interceptors : Array<DataInterceptor>;
	public var filters : Array<DataFilter>;
	
	
	function new() {
		connected = false;
		interceptors = new Array();
		filters = new Array();
	}
	
	
	public function connect() {}
	public function disconnect() : Bool { return throw new error.AbstractError();  }
	public function read( ?yes : Bool = true ) : Bool { return false; }
	public function send( data : String ) : Bool { return false;}
	
	
	function dataHandler( data : String ) {
		for( f in filters ) data = f.filterData( data );
		onData( data );
	}
	
}
