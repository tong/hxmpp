package jabber.core;

import jabber.StreamConnection;


/**
	Abstract base for jabber.StreamConnection.
*/
class StreamConnectionBase {

	public var onConnect : Void->Void;
	public var onDisconnect : Void->Void;
	public var onData : String->Void;
	public var onError : String->Void;
	public var connected(default,null) : Bool;
	public var interceptors : Array<DataInterceptor>;
	public var filters : Array<DataFilter>;
	
	
	function new() {
		connected = false;
		interceptors = new Array();
		filters = new Array();
	}
	
	
	public function connect() {}
	public function disconnect() : Void; //: Bool { return throw new error.AbstractError();  }
	public function read( ?yes : Bool = true ) : Bool { return false; }
	public function send( data : String ) : String { return null; }
	
	
	function dataHandler( data : String ) {
		for( f in filters ) {
			data = f.filterData( data );
		}
		onData( data );
	}
	
}
