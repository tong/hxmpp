package jabber;


typedef DataFilter = {
	/** Filters incoming data before further processing ( fe: uncompression ). */
	function filterData( data : String ) : String;
}

typedef DataInterceptor = {
	/** Modifies raw data before sending ( fe: compression ). */
	function interceptData( data : String ) : String;
}

typedef StreamConnection = {
	
	// TODO check filters,interceptors
	
	var onConnect : Void->Void;
	var onDisconnect : Void->Void;
	var onData : String->Void;
	var onError : Dynamic->Void;
	
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
	*/
	function read( ?yes : Bool ) : Bool;
	
}
