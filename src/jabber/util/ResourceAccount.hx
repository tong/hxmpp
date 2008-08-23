package jabber.util;


/**
	Utility for testing.
	Loads account data from a resource file attached at compilke time.
	The resource file must have the following format:
	
tong@disktree/hxjab
test
127.0.0.1
5222

*/
class ResourceAccount {

	public var jid(default,null) : String;
	public var password(default,null) : String;
	public var host(default,null) : String;
	public var port(default,null) : Int;
	
	
	public function new( ?id : String = "account" ) {
		try {
			var account = haxe.Resource.getString( id ).split( "\n" );
			jid = account[0];
			password = account[1];
			host = account[2];
			port = Std.parseInt( account[3] );
		} catch( e : Dynamic ) {
			throw "Error parsing account information";
		}
	}
	
	
	public function toString() : String {
		return "jabber.util.ResourceAccount("+jid+","+password+","+host+","+port+")";
	}
		
}
