package jabber.core;


/**
	Input/output connection interface for jabber streams.
*/
interface IStreamConnection {
	
	dynamic function onConnect() : Void;
	dynamic function onDisconnect() : Void;
	dynamic function onData( data : String ) : Void;
	
	var connected(default,null) : Bool;
	
	/** */
	function connect() : Void;
	
	/** */
	function disconnect() : Void;
	
	/** Inits/Stops input reading process */
	function read( ?active : Bool = true ) : Bool;	
	
	/** Send data */
	function send( data : String ) : Bool;

}
