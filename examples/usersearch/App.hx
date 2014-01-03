
class App extends XMPPClient {
	
	var search : jabber.UserSearch;
	
	override function onLogin() {
		
		super.onLogin();
		
		stream.sendPresence();
		
		search = new jabber.UserSearch( stream );
		search.onFields = onSearchFields;
		search.onResult = onSearchResult;
		search.requestFields( "search."+stream.jid.domain );
	}
	
	function onSearchFields( jid : String, f : xmpp.UserSearch ) {
		search.search( jid, cast { email : "mail@example.com" } );
	}
	
	function onSearchResult( jid : String, f : xmpp.UserSearch ) {
		trace( 'Search result: $jid' );
		for( i in f.items )
			trace(i);
	}
	
	static function main() {
		var creds = XMPPClient.readArguments();
		new App( creds.jid, creds.password, creds.ip, creds.http ).login();
	}

}
