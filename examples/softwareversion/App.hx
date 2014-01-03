
import haxe.ds.StringMap;

class App extends XMPPClient {
	
	var softwareVersions = new StringMap<xmpp.SoftwareVersion>();

	override function onLogin() {
		super.onLogin();
		var listener = new jabber.SoftwareVersionListener( stream, "hxmpp", "0.4.13" );
		stream.sendPresence();
	}

	override function onStreamClose(?e) {
		super.onStreamClose();
		softwareVersions = new StringMap<xmpp.SoftwareVersion>();
	}

	override function onPresence( p : xmpp.Presence ) {
		if( !softwareVersions.exists( p.from ) ) {
			var loader = new jabber.SoftwareVersion( stream );
			loader.onLoad = function( jid : String, version : xmpp.SoftwareVersion ) {
				softwareVersions.set( p.from, version );
				trace( 'Software version: ${version.name}, ${version.version}' );
				trace( 'OS: "+${version.os}' );
			};
			loader.load( p.from );
		}
	}

	static function main() {
		var creds = XMPPClient.readArguments();
		new App( creds.jid, creds.password, creds.ip, creds.http ).login();
	}
	
}
