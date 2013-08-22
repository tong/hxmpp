
import xmpp.dataform.FormType;

class App extends XMPPClient {
	
	static var ENTITY = "julia@jabber.disktree.net";
	
	override function onLogin() {
		new jabber.PresenceListener( stream, onPresence );
		stream.sendPresence();
	}
	
	function onPresence( p : xmpp.Presence ) {
		if( jabber.JIDUtil.bare( p.from ) == ENTITY ) {
			var disco = new jabber.ServiceDiscovery( stream );
			disco.onInfo = onDiscoInfo;
			disco.info( p.from );
		}
	}
	
	function onDiscoInfo( jid : String, info : xmpp.disco.Info ) {
		if( jabber.JIDUtil.bare( jid ) != ENTITY )
			return;
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
		trace( "Resource does not support dataforms" );
	}
	
	static function main() {
		new App().login();
	}
	
}
