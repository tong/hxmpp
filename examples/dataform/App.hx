
import xmpp.dataform.FormType;

using jabber.JIDUtil;

class App extends XMPPClient {
	
	static var ENTITY = "julia@jabber.disktree.net";
	
	override function onLogin() {
		super.onLogin();
		stream.sendPresence();
	}
	
	override function onPresence( p : xmpp.Presence ) {
		if( p.from.bare() != stream.jid.bare ) {
			var disco = new jabber.ServiceDiscovery( stream );
			disco.onInfo = onDiscoInfo;
			disco.info( p.from );
		}
	}
	
	function onDiscoInfo( jid : String, info : xmpp.disco.Info ) {
		for( f in info.features ) {
			if( f == xmpp.DataForm.XMLNS ) {
				var m = new xmpp.Message( jid, "fill the form" );
				var form = new xmpp.DataForm( xmpp.dataform.FormType.submit );
				var f = new xmpp.dataform.Field( xmpp.dataform.FieldType.text_single );
				f.label = "Wanna fuck ?";
				form.fields.push( f );
				m.properties.push( form.toXml() );
				stream.sendPacket( m );
				return;
			}
		}
	}
	
	static function main() {
		var creds = XMPPClient.readArguments();
		new App( creds.jid, creds.password, creds.ip, creds.http ).login();
	}
	
}
