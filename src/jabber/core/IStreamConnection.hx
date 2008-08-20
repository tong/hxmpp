package jabber.core;



/**
	Input/output connection interface for jabber streams.
*/
interface IStreamConnection {
	
	var connected(default,null) : Bool;
	var onConnect 		: Void->Void;
	var onDisconnect 	: Void->Void;
	var onData 			: String->Void;
//	dynamic function onConnect() : Void;
//	dynamic function onDisconnect() : Void;
//	dynamic function onData( data : String ) : Void;
	
	/** */
	function connect() : Void;
	
	/** */
	function disconnect() : Void;
	
	/** Inits/Stops input reading process */
	function read( ?active : Bool = true ) : Bool;	
	
	/** Send data */
	function send( data : String ) : Bool;
	
//	#if flash
//	var crossdomain : String;
//	#end
}
