package jabber.client;

import jabber.stream.Connection;

/**
	Base for client XMPP streams.<br>
*/
class Stream extends jabber.Stream {
	
	public static inline var STANDARD_PORT = 5222;
	public static inline var STANDARD_PORT_SECURE = 5223;
	public static var defaultPort = STANDARD_PORT;
	
	//TODO public var secure(default,null) : Bool;
	public var jid(default,null) : jabber.JID;
	
	public function new( jid : jabber.JID, cnx : Connection, version : Bool = true ) {
		super( cnx, jid );
		this.jid = jid;
		this.version = version;
		//this.secure = secure;
	}
	
	override function getJIDStr() : String {
		return jid.toString();
	}
	
	override function processStreamInit( t : String, buflen : Int ) : Int {
		var sei = t.indexOf( ">" );
		if( sei == -1 ) {
			return 0;
		}
		if( id == null ) { // parse open stream
			var s = t.substr( 0, sei ) + " />";
			var sx = Xml.parse( s ).firstElement();
			id = sx.get( "id" );
			if( !version ) {
				status = jabber.StreamStatus.open;
				onOpen();
				return buflen;
			}
		}
		if( id == null )
			throw new error.Exception( "Invalid XMPP stream, no id" );
		if( !version ) {
			status = jabber.StreamStatus.open;
			onOpen();
			return buflen;
		}
		var sfi = t.indexOf( "<stream:features>" );
		var sf = t.substr( t.indexOf( "<stream:features>" ) );
		if( sfi != -1 ) {
			try {
				var sfx = Xml.parse( sf ).firstElement();
				for( e in sfx.elements() ) {
					//trace(e.nodeName);
					server.features.set( e.nodeName, e );
				}
				#if XMPP_DEBUG
				jabber.XMPPDebug.incoming( sfx.toString() );
				#end
				status = jabber.StreamStatus.open;
				onOpen();
				return buflen;
			} catch( e : Dynamic ) {
				return 0;
			}
		}
		return buflen;
		//return throw "Never reached";
	}
	
	override function connectHandler() {
		status = jabber.StreamStatus.pending;
		sendData( xmpp.Stream.createOpenStream( xmpp.Stream.XMLNS_CLIENT, jid.domain, version, lang ) );
		cnx.read( true ); // start reading input
	}
	
	/*
	override function disconnectHandler() {
		id = null;
	}
	*/
	
}
