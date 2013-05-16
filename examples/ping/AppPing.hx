
class AppPing extends XMPPClient {
	
	override function onLogin() {
		
		stream.sendPresence();
		
		var ping = new jabber.Ping( stream, "julia@disktree/HXMPP" );
		ping.onPong = onPong;
		ping.onTimeout = onTimeout;
		ping.run( 1000 );
	}
	
	function onPong( jid : String ) {
		if( jid == null ) jid = "XMPP server";
		trace( "Pong from "+jid );
	}
	
	function onTimeout( jid : String ) {
		trace( "Pong timeout: "+jid );
	}
	
	static function main() {
		new AppPing( XMPPClient.getAccountFromFile(1) ).login();
	}
	
}
