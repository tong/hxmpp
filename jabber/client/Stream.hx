package jabber.client;

import jabber.JID;
import jabber.StreamConnection;
import jabber.StreamStatus;
import xmpp.Message;


/**
	TODO
*/
private class SASL {
	
	//public dynamic function onBindOffer<T>( stream : T ) {}
	//public dynamic function onBound<T>( stream : T ) {}
	
	//public var has : Bool;
	//public var use : Bool;
	public var negotiated : Bool;
	//public var implementedMechanisms : Hash<String>;
	public var availableMechanisms : Array<String>;
	//public var mechanismUsed : String;
	
	public function new( /*use : Bool = true*/ ) {
		
		negotiated = false;
		//implementedMechanisms = new Array();
		availableMechanisms = new Array();
	}
	
	//public function parseSASL( x : Xml ) {
	
	#if JABBER_DEBUG
	/*
	public function toString() : String {
		return "SASL(has=>"+has+",use=>"+use+")";
	}
	*/
	#end
	
}


/**
	Base for Client-2-Server jabber streams.<br>
*/
class Stream extends jabber.core.StreamBase {
	
	public static inline var STANDARD_PORT = 5222;
	public static var defaultPort = STANDARD_PORT;
	
	/** */
	public var jid(default,null) : JID;
	/** */
	public var sasl(default,null) : SASL;

//	var version : String;
	
	
	public function new( jid : JID, connection : StreamConnection, ?version : String = "1.0" ) {
		
		super( connection );
		this.jid = jid;
		this.version = version;
		
		sasl = new SASL();
	}
	
	
	/**
		Sends a "normal" type message.
		//TODO move to jabber.StreamBase
	*/
	public function sendMessage( to : String, subject : String, msg : String ) : xmpp.Message {
		return sendPacket( new xmpp.Message( xmpp.MessageType.normal, to, subject, msg, null, jid.toString() ) );
	}
	
	/**
		Sends a "chat" type message.
		//TODO move to jabber.StreamBase
	*/
	public function sendChatMessage( to : String, msg : String ) : xmpp.Message {
		return sendPacket( new Message( xmpp.MessageType.chat, to, null, msg, null, jid.toString() ) );
	}	
	
	override function processStreamInit( d : String ) {
		var sei = d.indexOf( ">" );
		if( id == null ) {
			// parse open stream
			var s = d.substr( 0, sei ) + " />";
			var sx = Xml.parse( s ).firstElement();
			id = sx.get( "id" );
			if( version == null ) {
				status = StreamStatus.open;
				onOpen( this );
				return;
			}
		}
		if( id == null ) {
			//TODO
			throw new error.Exception( "Invalid xmpp stream, no id given" );
		}
		// check for stream features
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
		status = StreamStatus.pending;
		sendData( xmpp.XMPPStream.createOpenStream( xmpp.XMPPStream.XMLNS_CLIENT, jid.domain, version, lang ) );
		connection.read( true ); // start reading input
	}
	
}
