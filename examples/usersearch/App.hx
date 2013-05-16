
class App extends XMPPClient {
	
	var usersearch : jabber.UserSearch;
	
	override function onLogin() {
		
		super.onLogin();
		stream.sendPresence();
		
		usersearch = new jabber.UserSearch( stream );
		usersearch.onFields = onSearchFields;
		usersearch.onResult = onSearchResult;
		usersearch.requestFields( "search.disktree" );
	}
	
	function onSearchFields( jid : String, f : xmpp.UserSearch ) {
		trace( "Search fields recieved ["+jid+"]:" );
		usersearch.search( jid, cast { email : "mail@example.com" } );
	}
	
	function onSearchResult( jid : String, f : xmpp.UserSearch ) {
		trace( "Search result recieved ["+jid+"]" );
		for( i in f.items ) trace( i );
	}
	
	static function main() {
		new App().login();
	}

}
