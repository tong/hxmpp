
import jabber.EntityCapabilities;

/**
	See: XEP-0085 Entity Capabilities: http://xmpp.org/extensions/xep-0115.html
*/
class App extends XMPPClient {
	
	var caps : EntityCapabilities;
	
	override function onLogin() {
		
		super.onLogin();
		
		// Add service discovery listener
		var identities = [{category:"client",type:"pc",name:"HXMPP"}];
		new jabber.ServiceDiscoveryListener( stream, identities );
		
		// Add some features to the stream for testing
		var pong = new jabber.Pong( stream );
		
		//
		caps = new EntityCapabilities( stream, "http://hxmpp.disktree.net/caps", identities );
		//caps.onCaps = onCaps;
		caps.onInfo = onCapsInfo;
		caps.onError = onCapsError;
		
		// Send initial presence
		stream.sendPresence();
		
		/*
		caps.publish( [{ category : "client", name : "HXMPP", type : "pc" },
					   { category : "client", name : "HXMPP", type : "mobile" }],
					   stream.features,
					   dataform );
		*/
	}
	
	/*
	function onCaps( jid : String, caps : xmpp.Caps ) {
		trace( "Entity capabilities from "+jid+":\n", "info" );
		trace( "\thash: "+caps.hash, "info" );
		trace( "\tver: "+caps.ver, "info" );
		trace( "\tnode: "+caps.node, "info" );
		trace( "\text: "+caps.ext, "info" );
	}
	*/
	
	function onCapsInfo( jid : String, info : xmpp.disco.Info, ?ver : String ) {
		trace( "Entity capabilities infos "+jid+":" );
		if( ver != null )
			trace( "( Capabilities got cached with verification string: "+ver+" )" );
		trace( "Identities:" );
		for( i in info.identities )
			trace( "\t\tname: "+i.name+" , type: "+i.type+" , category: "+i.category );
		trace( "Features:" );
		for( f in info.features )
			trace( "\t\t"+f );
		//trace( Lambda.count( caps.cached )+" cached entity capabilities" );
	}
	
	function onCapsError( e ) {
		trace( e );
	}
	
	static function main() {
		var creds =  XMPPClient.getAccountCredentials( 'romeo.json' );
		new App( creds ).login();
	}
}
