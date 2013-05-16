
class AppRomeo extends App {
	
	static function main() {
		new AppRomeo( XMPPClient.getAccountFromFile(1) ).login();
	}
}
