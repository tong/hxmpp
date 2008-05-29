



/**
	Custom jabber stream providing basic IM functionality.
*/
private class CustomStream extends jabber.client.Stream {
	
	public var authentication : NonSASLAuth;
	public var roster : Roster;
	public var service : ServiceDiscovery;
	public var chats : ChatManager;
	public var muc : MUChat;
	
	
	public function new() {
		
		
		connection = new StreamSocketConnection();
		
	}
}




/**
	flash9, neko, js.
*/
class SimpleClient {

	static var TEST_JID = "tong@disktree/hxjab";
	static var TEST_PW  = "test";
	
	static function main() {
	}
}
