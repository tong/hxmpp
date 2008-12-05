package jabber;


typedef DataFilter = {
	/** Filters incoming data before further processing ( fe: uncompression ). */
	function filterData( d : String ) : String;
}

typedef DataInterceptor = {
	/** Modifies raw data before sending ( fe: compression ). */
	function interceptData( d : String ) : String;
}


typedef StreamConnection = {
	
	var onConnect : Void->Void;
	var onDisconnect : Void->Void;
	var onData : String->Void;
	var onError : String->Void;
	
	var connected(default,null) : Bool;
	var interceptors : Array<DataInterceptor>;
	var filters : Array<DataFilter>;
	
	/**
	*/
	function connect() : Void;
	
	/**
	*/
	function disconnect() : Bool;
	
	/**
	*/
	function send( data : String ) : Bool;
	
	/**
		Starts/Stops reading from input.
	*/
	function read( ?yes : Bool ) : Bool;
	
}
