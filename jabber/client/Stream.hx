package jabber.client;


/**
	Base for client XMPP streams.<br>
*/
class Stream extends jabber.Stream {
	
	public static inline var STANDARD_PORT = 5222;
	public static var defaultPort = STANDARD_PORT;
	
	
	public function new( jid : jabber.JID, cnx : jabber.StreamConnection, version : Bool = true ) {
		super( cnx, jid );
		this.version = version;
	}

	
	override function processStreamInit( d : String ) {
		var sei = d.indexOf( ">" );
		if( id == null ) { // parse open stream
			var s = d.substr( 0, sei ) + " />";
			var sx = Xml.parse( s ).firstElement();
			id = sx.get( "id" );
			if( !version ) {
				status = jabber.StreamStatus.open;
				onOpen();
				return;
			}
		}
		if( id == null ) {
			//TODO
			throw new error.Exception( "Invalid XMPP stream, no id" );
		}
		// check stream features
		var sfi =  d.indexOf( "<stream:features>" );
		var sf = d.substr( d.indexOf( "<stream:features>" ) );
		if( sfi != -1 ) {
			// get stream features
			var fx = Xml.parse( sf ).firstElement();
			for( e in fx.elements() )
				server.features.set( e.nodeName, e );
			// report open
			if( status != jabber.StreamStatus.open ) {
				status = jabber.StreamStatus.open;
				onOpen();
			}
		}
	}
	
	override function connectHandler() {
		status = jabber.StreamStatus.pending;
		sendData( xmpp.Stream.createOpenStream( xmpp.Stream.XMLNS_CLIENT, jid.domain, version, lang ) );
		cnx.read( true ); // start reading input
	}
	
}
