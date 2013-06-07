
class AppRomeo extends App {
	
	static function main() {
		var app = new AppRomeo( XMPPClient.getAccountFromFile() );
		var entity = XMPPClient.getAccountFromFile("b");
		app.entity = entity.user+"@"+entity.host+"/"+app.getResource();
		app.login();
	}
	
}
