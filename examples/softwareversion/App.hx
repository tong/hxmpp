
class App extends XMPPClient {
	
	override inline function getResource() {
		return "hxmpp";
	}

	override function onLogin() {
		stream.sendPresence();
	}
	
}
