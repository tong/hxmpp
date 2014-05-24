
class App extends XMPPClient {
	
	override function onLogin() {
		
		var pong = new jabber.Pong( stream );
		pong.onPong = function(jid:String) { trace( "Sent pong to: "+jid ); }
		
		stream.sendPresence();
		
		var ping = new jabber.Ping( stream );
		ping.onPong = onPong;
		ping.send( stream.jid.domain );
	}
	
	function onPong( jid : String ) {
		if( jid == null ) jid = "XMPP server";
		trace( 'Pong: $jid' );
	}
	
	static function main() {
		var creds = XMPPClient.readArguments();
		new App( creds.jid, creds.password, creds.ip, creds.http ).login();
	}
	
}
