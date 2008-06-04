package jabber;



/**
	Input/output connection interface for jabber streams.
*/
interface IStreamConnection {
	
	var connected(default,null) : Bool;
	var onConnect 		: Void->Void;
	var onDisconnect 	: Void->Void;
	var onData 			: String->Void;
	
	/** */
	function connect() : Void;
	
	/** */
	function disconnect() : Void;
	
	/** Inits/Stops input reading process */
	function read( ?active : Bool ) : Bool;	
	
	/** Send data */
	function send( data : String ) : Bool;
	
//	#if flash
//	var crossdomain : String;
//	#end
}
