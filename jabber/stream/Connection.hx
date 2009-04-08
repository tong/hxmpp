package jabber.stream;


typedef DataFilter = {
	/** Filters incoming data before further processing ( fe: uncompression ). */
	function filterData( d : String ) : String;
}

typedef DataInterceptor = {
	/** Modifies raw data before sending ( fe: compression ). */
	function interceptData( d : String ) : String;
}

/**
	Abstract base for XMPP stream connections.
*/
class Connection {
	
	/** Callback for connecting event */
	public var onConnect : Void->Void;
	/** Callback for disconnecting event */
	public var onDisconnect : Void->Void;
	/** Callback data recieved event */
	public var onData : String->Void;
	/** Callback connection level errors */
	public var onError : String->Void;
	
	//TODO
	//public var input : haxe.io.Input;
	//public var output : haxe.io.Output;
	
	/** Indicates whether is currently connected. */
	public var connected(default,null) : Bool;
	/** Raw data filters for outgoing data. */
	public var interceptors : Array<DataInterceptor>;
	/** Raw data filters for incoming data. */
	public var filters : Array<DataFilter>;
	
	function new() {
		connected = false;
		interceptors = new Array();
		filters = new Array();
	}
	
	/**
		Try to connect the stream data connection.
	*/
	public function connect() {
		throw new error.AbstractError();
	}
	
	/**
		Disconnects stream connection.
	*/
	public function disconnect() { //: Bool
		throw new error.AbstractError();
	}
	
	/**
		Starts/Stops reading data input.
	*/
	public function read( ?yes : Bool = true ) : Bool {
		return throw new error.AbstractError();
	}
	
	/**
		Send string.
	*/
	public function write( t : String ) : String {
		return throw new error.AbstractError();
	}
	
	/**
		Send raw bytes.
		TODO
	public function writeBytes( t : haxe.io.Bytes ) : haxe.io.Bytes {
		return throw new error.AbstractError();
	}
	*/
	
	function dataHandler( t : String ) {
		for( f in filters )
			t = f.filterData( t );
		onData( t );
	}
	
}
