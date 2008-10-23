package jabber.util;


/**
	Utility for testing.
	Loads account data from a resource file attached at compile time:
	
	<b>EOF</b>
	jid
	password
	host
	port
	<b>EOF</b>
	
*/
class ResourceAccount {

	public var jid(default,null) : String;
	public var password(default,null) : String;
	public var host(default,null) : String;
	public var port(default,null) : Int;
	
	public function new( ?id : String = "account" ) {
		var account : Array<String>;
		try {
			account = haxe.Resource.getString( id ).split( "\n" );
			jid = account[0];
			password = account[1];
		} catch( e : Dynamic ) {
			throw new error.Exception( "Error parsing account information" );
		}
		host = account[2] == "" ? null : account[2];
		port = ( account[3] == "" || account[3] == null )  ? null : Std.parseInt( account[3] );
	}
	
	public function toString() : String {
		return "jabber.util.ResourceAccount("+jid+","+password+","+host+","+port+")";
	}
		
}
