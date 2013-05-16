
class AppRomeo extends App {
	
	static function main() {
		var app = new AppRomeo( XMPPClient.getAccountFromFile(1) );
		app.entity = "julia@disktree";
		app.login();
	}
	
}
