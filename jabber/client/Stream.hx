package jabber.client;

import jabber.JID;
import jabber.StreamConnection;
import jabber.StreamStatus;
import xmpp.Message;


/**
	Base for Client-2-Server jabber streams.<br>
*/
class Stream extends jabber.core.StreamBase {
	
	public static inline var STANDARD_PORT = 5222;
	public static var defaultPort = STANDARD_PORT;
	
	
	public function new( jid : JID, cnx : StreamConnection,
						 version : Bool = true ) {
		
		super( cnx, jid );
		this.version = version;
	}
	
	/*
	function setJID( j : JID ) : JID {
		if( status != closed ) throw "Cannot change jid on active jid";
		return jid = j;
	}
	
	override function getJID() : String {
		return jid.toString();
	}
	*/
	
	override function processStreamInit( d : String ) {
		
		trace("processStreamInit\n");
		
		var sei = d.indexOf( ">" );
		if( id == null ) { // parse open stream
			var s = d.substr( 0, sei ) + " />";
			var sx = Xml.parse( s ).firstElement();
			id = sx.get( "id" );
			if( !version ) {
				status = StreamStatus.open;
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
			if( status != StreamStatus.open ) {
				status = StreamStatus.open;
				onOpen( this );
			}
		}
	}
	
	override function connectHandler() {
		
		trace("connectHandler\n");
		
		status = StreamStatus.pending;
		sendData( xmpp.Stream.createOpenStream( xmpp.Stream.XMLNS_CLIENT, jid.domain, version, lang ) );
		connection.read( true ); // start reading input
	}
	
}
