package jabber.client;

import jabber.JID;
import jabber.StreamConnection;
import jabber.StreamStatus;
import xmpp.Message;


/**
	TODO
*/
private class SASL {
	
	//public var has : Bool;
	//public var use : Bool;
	public var negotiated : Bool;
	public var resourceBound : Bool;
	/** SASL mechanisms offered by server */
	public var availableMechanisms : Array<String>;
	//public var mechanismUsed : String;
	
	public function new( /*use : Bool = true*/ ) {
		negotiated = false;
		availableMechanisms = new Array();
	}
	
	/*
	#if JABBER_DEBUG
	public function toString() : String {
		return "SASL(has=>"+has+",use=>"+use+")";
	}
	#end
	*/
}


/**
	Base for Client-2-Server jabber streams.<br>
*/
class Stream extends jabber.core.StreamBase {
	
	public static inline var STANDARD_PORT = 5222;
	public static var defaultPort = STANDARD_PORT;
	
	public var jid(default,setJID) : JID;
	public var sasl(default,null) : SASL;
	public var version : String;
	
	
	public function new( jid : JID, connection : StreamConnection,
						 ?version : String = "1.0" ) {
		
		super( connection );
		this.jid = jid;
		this.version = version;
		
		sasl = new SASL();
	}
	
	
	function setJID( j : JID ) : JID {
		if( status != closed ) throw "Cannot change jid on active jid";
		return jid = j;
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
	
	override function parseStreamFeatures( x : Xml ) {
		var f = new haxe.xml.Fast( x );
		if( f.hasNode.mechanisms && f.node.mechanisms.has.xmlns && f.node.mechanisms.att.xmlns == "urn:ietf:params:xml:ns:xmpp-sasl"  ) {
			sasl.availableMechanisms = xmpp.SASL.parseMechanisms( f.node.mechanisms.x );
		}
		//..
		return null;
	}
	
}
