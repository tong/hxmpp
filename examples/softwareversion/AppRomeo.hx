
/**
	Requests another entity for the 'SoftwareVersion'
*/
class AppRomeo extends App {
	
	override function onLogin() {
		
		super.onLogin();
		
		var sv = new jabber.SoftwareVersion( stream );
		sv.onLoad = function( jid : String, swv : xmpp.SoftwareVersion ) {
			trace( "SoftwareVersion of "+jid+": "+swv.name+" "+swv.version+", Operating system: "+swv.os, "info" );
		};
		sv.load( "julia@"+stream.jid.domain+"/hxmpp" );
	}
	
	static function main() {
		new AppRomeo().login();
	}
	
}
