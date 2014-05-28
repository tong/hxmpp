
import XMPPClient;

class App extends XMPPClient {
	
	var disco : jabber.ServiceDiscovery;
	var target : String; // Jid of discovered entity
	
	override function onLogin() {
		
		super.onLogin();
		
		new jabber.PresenceListener( stream, onPresence );
		
		// Some random stream features to test disco request responses
		new jabber.Pong( stream );
		new jabber.LastActivityListener( stream );
		
		// Listen for discovery requests
		new jabber.ServiceDiscoveryListener( stream, [{category:"client",type:"pc",name:"HXMPP"}] );
		
		stream.sendPresence();
		
		disco = new jabber.ServiceDiscovery( stream );
		
		disco.onInfo = onDiscoInfo;
		disco.info( target ); // discover server info

		disco.onItems = onDiscoItems;
		disco.items( target ); // discover server items
	}
	
	override function onPresence( p : xmpp.Presence ) {
		var jid = new jabber.JID( p.from );
		if( jid.bare != stream.jid.bare && p.type == null ) {
			disco.info( p.from );
		}
	}
	
	function onDiscoInfo( jid : String, info : xmpp.disco.Info ) {
		Sys.println( 'Disco info [$jid]' );
		Sys.println( "  identities:" );
		for( identity in info.identities )
			Sys.println( "    name: "+identity.name+" , type: "+identity.type+" , category: "+identity.category );
		Sys.println( "  features:" );
		for( feature in info.features )
			Sys.println( "    "+feature  );
	}
	
	function onDiscoItems( node : String, items : xmpp.disco.Items ) {
		Sys.println( 'Disco items [$node]:'  );
		if( items.length == 0 ) {
			Sys.println( "No items" );
			return;
		}
		var recieved = new Array<String>();
		for( i in items ) {
			trace( "\t"+i.jid+" , "+i.name );
			recieved.push( i.jid );
		}
		for( r in recieved ) {
			disco.info( r );
			disco.items( r );
		}
	}
	
	static function main() {
		var creds = XMPPClient.readArguments();
		var client = new App( creds.jid, creds.password, creds.ip, creds.http );
		client.target = 'jabber.disktree.net';
		client.login();
	}

}
