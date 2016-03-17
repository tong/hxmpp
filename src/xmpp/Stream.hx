package xmpp;

import haxe.crypto.Base64;
import xmpp.IQ;

using StringTools;

private typedef Header = {
	var to : String;
	var from : String;
	var id : String;
	//var lang : String;
	var version : String;
}

class Stream {

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
		sendHeader();
    }

	public function close() {
		sendString( '</stream:stream>' );
	}

	public function send( stanza : Stanza ) {
		sendXml( stanza.toXml() );
	}

	public function sendXml( xml : Xml ) {
		sendString( xml.toString() );
	}

	public function sendString( str : String ) {
		onSend( str );
	}

	public function sendQuery( iq : IQ, callback : IQResponse->Void ) {
        if( iq.id == null ) iq.id = Std.string( randomStanzaId() );
		pending.set( iq.id, function(r) switch r.type {
			case result: callback( IQResponse.result( r.payload ) );
			case error: callback( IQResponse.error( r.payload ) );
			default:
			}
		);
		send( iq );
    }

	public function handle( xmlns : String, handler : XML->Void ) {
		handlers.set( xmlns, handler );
	}

	public function unhandle( xmlns : String ) {
		handlers.remove( xmlns );
	}

	public function receive( str : String ) : Bool {
		//if( StringTools.fastCodeAt( str, str.length-1 ) != 62 ) {
		//if( str.fastCodeAt( str.length-1 ) != '>'.code ) {
		if( str.charAt( str.length-1 ) != '>' ) {
            buf.add( str );
			return false;
		}
		buf.add( str );
		return _receive( buf.toString() );
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

	function _receive( str : String ) : Bool {
		return false;
	}

	function sendHeader() {
	}

	function reset() {
		id = null;
		buf = new StringBuf();
		handlers = new Map();
		pending = new Map();
	}

	function randomStanzaId( len = 8 ) : String {
		var buf = new StringBuf();
		var n = Base64.CHARS.length - 2;
		for( i in 0...len )
			buf.add( Base64.CHARS.charAt( Std.random( n ) ) );
		return buf.toString();
	}

	public static function createInitElement( xmlns : String, to : String, ?version : Bool, ?lang : String, xmlDecl = true ) : String {
		var b = new StringBuf();
		if( xmlDecl )
			b.add( '<?xml version="1.0" encoding="UTF-8"?>' );
		b.add( '<stream:stream xmlns="' );
		b.add( xmlns );
		b.add( '" xmlns:stream="' );
		b.add( 'http://etherx.jabber.org/streams' );
		b.add( '" ' );
		if( to != null ) {
			b.add( 'to="' );
			b.add( to );
		}
		b.add( '" xmlns:xml="http://www.w3.org/XML/1998/namespace"' );
		if( version )
			b.add( ' version="1.0"' );
		if( lang != null ) {
			b.add( ' xml:lang="' );
			b.add( lang );
			b.add( '"' );
		}
		b.add( '>' );
		return b.toString();
	}

	public static function readHeader( s : String ) : Header {
		var r = ~/^(<\?xml) (.)+\?>/; //TODO remove
		if( r.match(s) )
			s = r.matchedRight();
		var i = s.indexOf( ">" );
		if( i == -1 )
			throw 'invalid xmpp'; //TODO??
		s = s.substr( 0, i )+" />";
		var x = Xml.parse(s).firstElement();
		return {
    		id : x.get( "id" ),
    		from : x.get( "from" ),
    		to : x.get( "to" ),
    		version : x.get( "version" ),
    		//h.lang = x.get( "lang" );
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
