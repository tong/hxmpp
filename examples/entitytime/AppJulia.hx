
class AppJulia extends App {
	
	static function main() {
		var app = new AppJulia( XMPPClient.getAccountFromFile(2) );
		app.entity = "romeo@disktree/HXMPP";
		app.login();
	}
	
}
