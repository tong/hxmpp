
/**
	Listens for and responses to 'SoftwareVersion' requests
*/
class AppJulia extends App {
	
	override function onLogin() {
		super.onLogin();
		var listener = new jabber.SoftwareVersionListener( stream, "HXMPP", "0.4.13" );
	}
	
	static function main() {
		new AppJulia( XMPPClient.getAccountFromFile("b")).login();
	}
	
}
