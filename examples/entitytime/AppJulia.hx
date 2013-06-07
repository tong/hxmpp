
class AppJulia extends App {
	
	static function main() {
		var app = new AppJulia( XMPPClient.getAccountFromFile("b") );
		var entity = XMPPClient.getAccountFromFile("a");
		app.entity = entity.user+"@"+entity.host+"/"+app.getResource();
		app.login();
	}
	
}
