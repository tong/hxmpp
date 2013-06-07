
class AppJulia extends App {
	
	static function main() {
		new AppJulia( XMPPClient.getAccountFromFile("b") ).login();
	}
}
