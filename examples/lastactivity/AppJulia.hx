
class AppJulia extends App {
	
	static function main() {
		new AppJulia( XMPPClient.getAccountCredentials("julia") ).login();
	}
}
