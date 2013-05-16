
/**
	Listens for and responses to 'SoftwareVersion' requests
*/
class AppJulia extends XMPPClient {
	
	override function onLogin() {
	
		stream.sendPresence();
		
		var listener = new jabber.SoftwareVersionListener( stream, "HXMPP", "0.4.8" );
	}
	
	static function main() {
		new AppJulia( XMPPClient.getAccountFromFile(1) ).login();
	}
	
}
