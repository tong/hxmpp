package xmpp;

import haxe.crypto.Base64;
import xmpp.IQ;
import xmpp.Message;
import xmpp.Presence;

using StringTools;

typedef Header = {
	var to : String;
	var from : String;
	var id : String;
	var lang : String;
	var version : String;
}

class Stream {

	public static inline var XMLNS = 'http://etherx.jabber.org/streams';

	public dynamic function onReady() {}
	public dynamic function onSend( str : String ) {}
	//public dynamic function onReceive( str : String ) {}
	public dynamic function onEnd() {}

	public dynamic function onMessage( m : Message ) {}
	public dynamic function onPresence( m : Presence ) {}

	public var xmlns(default,null) : String;
	public var id(default,null) : String;
	public var lang(default,null) : String;

	var buf : StringBuf;
	var handlers : Map<String,Xml->Void>;
	var pending : Map<String,IQ->Void>;

	function new( xmlns : String, ?lang : String ) {
		this.xmlns = xmlns;
        this.lang = lang;
		reset();
	}

	public function open() {
	}

	public function close() {
		send( '</stream:stream>' );
	}

	public function send( str : String ) {
		onSend( str );
	}

	/*
	public function send( stanza : Stanza ) {
		sendXml( stanza.toXml() );
	}

	public function sendXml( xml : Xml ) {
		sendString( xml.toString() );
	}

	public function send<T:{t:String}>( stringProvider : T ) {
		sendString( stringProvider.toString() );
	}
	*/

	public function sendMessage( to : String, body : String, ?subject : String, ?type : Null<MessageType>, ?thread : String, ?from : String ) {
		send( new Message( to, body, subject, type, thread, from ).toString() );
	}

	public function sendPresence( ?show : PresenceShow, ?status : String, ?priority : Int, ?type : PresenceType ) {
		send( new Presence( show, status, priority, type ).toString() );
	}

	public function sendQuery( iq : IQ, callback : IQResponse->Void ) {
        if( iq.id == null ) iq.id = Std.string( randomStanzaId() );
		pending.set( iq.id, function(r) switch r.type {
			case result: callback( result( r.payload ) );
			case error: callback( error( r.payload ) );
			default:
			}
		);
		send( iq );
    }

	//public function extend( xmlns : String, handler : XML->Void ) {
	public function handle( xmlns : String, handler : XML->Void ) {
		handlers.set( xmlns, handler );
	}

	public function unhandle( xmlns : String ) {
		handlers.remove( xmlns );
	}

	public function receive( str : String ) : Bool {
		//if( StringTools.fastCodeAt( str, str.length-1 ) != 62 ) {
		//if( str.fastCodeAt( str.length-1 ) != '>'.code ) {
		if( str == null )
			return true;
		buf.add( str );
		//if( str.fastCodeAt( str.length-1 ) != 62 ) // >
		if( !str.endsWith( '>' ) ) // >
			return false;
		//if( str.charAt( str.length-1 ) != '>' )
		var str = buf.toString();
		buf = new StringBuf();
		return _receive( str );
	}

	public function receiveXml( xml : XML ) {
		var xmlns = xml.ns();
		if( xmlns != null && handlers.exists( xmlns ) ) {
			var h = handlers.get( xmlns );
			h( xml );
			return;
		}
		switch xml.name {
		case 'iq':
			var iq :IQ = xml;
			switch iq.type {
			case result:
				if( pending.exists( iq.id ) ) {
					var h = pending.get( iq.id );
					pending.remove( iq.id );
					h( iq );
				}
			default:
				var xmlns = iq.payload.get( 'xmlns' );
				//if( listeners.exists( xmlns ) ) {
			}
		}
	}

	public function reset() {
		id = null;
		buf = new StringBuf();
		handlers = new Map();
		pending = new Map();
	}

	function _receive( str : String ) : Bool {
		return false;
	}

	function randomStanzaId( len = 8 ) : String {
		var buf = new StringBuf();
		var n = Base64.CHARS.length - 2;
		for( i in 0...len )
			buf.add( Base64.CHARS.charAt( Std.random( n ) ) );
		return buf.toString();
	}

	public static function createInitElement( xmlns : String, to : String, ?version : Bool, ?lang : String, xmlDecl = true ) : String {
		var xml = XML.create( 'stream:stream' )
			.set( 'xmlns', xmlns )
			.set( 'xmlns:stream', XMLNS )
			//.set( 'xmlns:xml', 'http://www.w3.org/XML/1998/namespace' )
			.set( 'to', to );
		if( version ) xml.set( 'version', '1.0' );
		if( lang != null ) xml.set( 'xml:lang', lang );
		var s = xml.toString();
		return s.substr( 0, s.lastIndexOf( '/' ) ) + '>';
	}

	public static function readHeader( s : String ) : Header {
		var r = ~/^(<\?xml) (.)+\?>/; //TODO remove
		if( r.match(s) )
			s = r.matchedRight();
		var i = s.indexOf( ">" );
		if( i == -1 )
			throw 'invalid xmpp'; //TODO??
		s = s.substr( 0, i )+" />";
		var x = XML.parse(s);
		return {
    		id : x.get( "id" ),
    		from : x.get( "from" ),
    		to : x.get( "to" ),
    		version : x.get( "version" ),
			lang : x.get( "lang" )
        };
	}

	public static function readFeatures( s : String ) : Map<String,Xml> {
		var i = s.indexOf( "<stream:features>" );
		if( i != -1 ) {
			s = s.substr( i );
			var x = Xml.parse(s).firstElement();
			var x : Xml;
			try x = Xml.parse(s).firstElement() catch( e : Dynamic ) {
				trace(e); //TODO
				return null;
			}
			var map = new Map();
			for( e in x.elements() )
				map.set( e.nodeName, e );
			return map;
		}
		return null;
	}
}
