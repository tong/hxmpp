package xmpp;

import haxe.crypto.Md5;
import xmpp.IQ;

using StringTools;

private typedef Header = {
	from : String,
	to : String,
	id : String,
	lang : String,
	version : String
}

class Stream {

	public static inline var XMLNS = 'http://etherx.jabber.org/streams';

	public dynamic function onMessage( m : Message ) {}
	public dynamic function onPresence( p : Presence ) {}
	public dynamic function onIQ( iq : IQ ) {}

	public final xmlns : String;
	public final domain : String;
	public final lang : String;
	
	public var id(default,null) : String;
	public var version(default,null) = "1.0";
	
	public var ready(default,null) = false;
	public var extensions = new Map<String,IQ->Void>();
	public var output : String->Void;

	var input : String->Void;
	var buffer : StringBuf;
	var queries : Map<String,IQ->Void>;

	function new( xmlns : String, domain : String, ?lang : String ) {
		this.xmlns = xmlns;
		this.domain = domain;
        this.lang = lang;
		version = '1.0';
	}

	public function recv( str : String ) {
		if( str == null || str.length == 0 )
			return;
		if( buffer == null ) buffer = new StringBuf();
		buffer.add( str );
		if( !str.endsWith( '>' ) )
			return;
		if( str.endsWith( '>' ) ) {
			var received = buffer.toString();
			buffer = new StringBuf();
			input( received );
		}
	}

	public function send( xml : XML ) {
		output( xml );
	}

	public function get( payload : XML, ?jid : String, callback : (response:IQ)->Void ) {
		var iq = new IQ( payload, IQType.get, createRandomStanzaId(), jid );
		query( iq, callback );
	}

	public function set( payload : XML, ?jid : String, callback : (response:IQ)->Void ) {
		var iq = new IQ( payload, IQType.set, createRandomStanzaId(), jid );
		query( iq, callback );
	}

	/*
	public inline function result( iq : IQ, content : XML ) {
		send( new IQ( IQType.result, iq.from, iq.to, iq.id, content ) );
	}
	*/

	public function query( iq : IQ, callback : (response:IQ)->Void ) {
		if( iq.id == null ) iq.id = createRandomStanzaId();
		queries.set( iq.id, cast callback );
		send( iq );
	}

	//public function end( ?error : StreamError ) {
	public function end() {
		output( '</stream:stream>' );
		reset();
	}

	function handleString( str : String ) {
		var xml : XML;
		try xml = XML.parse( str ) catch(e:Dynamic) {
			trace(e);
			return;
		}
		handleXML( xml );
	}

	function handleXML( xml : XML ) {
		if( xml.has( 'xmlns' ) ) {
			if( xml.get( 'xmlns' ) != this.xmlns ) {
				trace( "invalid stream namespace" );
				return;
			}
		}
	}

	function reset() {
		ready = false;
		buffer = new StringBuf();
		queries = new Map();
		//extensions = new Map(); //TODO: ?
	}

	function createRandomStanzaId( length = 8 ) : String {
		return Std.string( Md5.encode( id + Date.now().getTime() ) ).substr( 0, length );
	}

	static function createHeader( xmlns : String, to : String, ?version : String, ?lang : String ) : String {
		var xml = XML.create( 'stream:stream' )
			.set( 'xmlns', xmlns )
			.set( 'xmlns:stream', xmpp.Stream.XMLNS )
			.set( 'to', to );
		if( version != null ) xml.set( 'version', version );
		if( lang != null ) xml.set( 'xml:lang', lang );
		var str = xml.toString();
		str = str.substr( 0, str.lastIndexOf( '/' ) ) + '>';
		return str;
		//return '<?xml version="1.0" encoding="UTF-8"?>'+str;
	}

	static function readHeader( str : String ) : Header {
		var r = ~/^(<\?xml) (.)+\?>/; //TODO remove (?)
		if( r.match( str ) ) {
			str = r.matchedRight();
		}
		//TODO handle stream:error
		//var i = str.lastIndexOf( "/>" );
		if( !str.endsWith( '/>' ) ) {
			var i = str.indexOf( ">" );
			if( i == -1 )
				throw 'invalid xmpp'; //TODO??
			str = str.substr( 0, i ) +  '/>';
		}
		var xml = XML.parse( str );
		return {
    		id : xml.get( "id" ),
    		from : xml.get( "from" ),
    		to : xml.get( "to" ),
    		version : xml.get( "version" ),
			lang : xml.get( "lang" )
        };
	}

	/*
	static function readError( str : String ) : XML {
		var i = str.indexOf( "<stream:error" );
		if( i == -1 )
			return null;
		return str;
	}
	*/

	static function readFeatures( str : String ) : XML {
		var i = str.indexOf( "<stream:features" );
		if( i == -1 )
			return null;
		str = str.substr( i );
		i = str.indexOf( "</stream:stream>" );
		if( i != -1 ) 	str = str.substr( 0, i );
		return str;
	}

}
