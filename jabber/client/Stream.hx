package jabber.client;

import jabber.JID;
import jabber.StreamConnection;


/**
	Base for Client-2-Server jabber streams.<br>
*/
class Stream extends jabber.StreamBase {
	
	public static inline var STANDARD_PORT = 5222;
	public static var defaultPort = STANDARD_PORT;
	
	
	public function new( jid : JID, cnx : StreamConnection,
						 version : Bool = true ) {
		
		super( cnx, jid );
		this.version = version;
	}
	
	
	#if JABBER_DEBUG
	public function toString() : String {
		return "JabberClientStream("+jid+","+status+")";
	}
	#end
	
	
	override function processStreamInit( d : String ) {
		var sei = d.indexOf( ">" );
		if( id == null ) { // parse open stream
			var s = d.substr( 0, sei ) + " />";
			var sx = Xml.parse( s ).firstElement();
			id = sx.get( "id" );
			if( !version ) {
				status = jabber.StreamStatus.open;
				onOpen( this );
				return;
			}
		}
		if( id == null ) {
			//TODO
			throw new error.Exception( "Invalid xmpp stream, no id" );
		}
		// check stream features
		var sfi =  d.indexOf( "<stream:features>" );
		var sf = d.substr( d.indexOf( "<stream:features>" ) );
		if( sfi != -1 ) {
			//TODO
			parseStreamFeatures( Xml.parse( sf ).firstElement() );
			if( status != jabber.StreamStatus.open ) {
				status = jabber.StreamStatus.open;
				onOpen( this );
			}
		}
	}
	
	override function connectHandler() {
		status = jabber.StreamStatus.pending;
		sendData( xmpp.Stream.createOpenStream( xmpp.Stream.XMLNS_CLIENT, jid.domain, version, lang ) );
		cnx.read( true ); // start reading input
	}
	
}
