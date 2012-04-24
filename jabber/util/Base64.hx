package jabber.util;

import haxe.io.Bytes;
#if nodejs
import js.Node;
#end

/**
	Base64 encoding/decoding utility.
*/
class Base64 {
	
	public static var CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
	
	#if (cpp||flash||js||neko||java||cs)

	static var bc = new haxe.BaseCode( Bytes.ofString( CHARS ) );
	
	static function getNullbits( s : String ) : String {
	 	var n = s.length%3;
	 	if( n == 0 )
	 		return "";
	 	var r = "";
	 	for( i in n...3 ) r += "=";
	 	return r;
	}
	
	public static inline function fillNullbits( s : String ) : String {
		return s + getNullbits(s);
	}
	
	public static function removeNullbits( s : String ) : String {
		var p = s.length-1;
		while( s.charAt( p ) == "=" ) {
			p--;
		}
		return s.substr( 0, p+1 );
	}
	
	#end
	
	public static
	//#if (nodejs||php) #end
	function encode( s : String ) : String {
		#if nodejs
		return new Buffer(s).toString( Node.BASE64 );
		//return new Buffer( s, Node.BASE64 ).toString( Node.UTF8 );
		#elseif php
		return untyped __call__( "base64_encode", s );
		#else
			#if js
	        //if( untyped window != null && untyped window.atob != null )
	        //	return untyped window.atob( s );
	        #end
	        //TODO wtf
	      	s = removeNullbits( s );
	        var p = getNullbits(s);
	        var r = bc.encodeString( s );
	        return r+p;
	       // var r = bc.encodeString( s );
	       // return fillNullbits(r);
		#end
	}
	
	public static inline function decode( s : String ) : String {
		#if nodejs
		return new Buffer( s, Node.BASE64 ).toString( Node.ASCII );
		#elseif php
		return untyped __call__( "base64_decode", s );
		#else
		return bc.decodeString( removeNullbits(s) );
		#end
	}
	
	public static inline function encodeBytes( b : Bytes ) : String {
		#if php
		return untyped __call__( "base64_encode", b.getData() );
		#elseif nodejs
		return b.getData().toString( Node.BASE64 );
		#else
		return fillNullbits( bc.encodeBytes( b ).toString() );
		#end
	}
	
	public static inline function decodeBytes( s : String ) : Bytes {
		#if php
		return Bytes.ofString( untyped __call__( "base64_decode", s ) );
		#elseif nodejs
		return Bytes.ofData( new Buffer( s, Node.BASE64 ) );
		#else
		return bc.decodeBytes( Bytes.ofString( removeNullbits( s ) ) );
		#end
	}
	
	/**
		Create a random (base64 compatible) string of given length.
	*/
	public static function random( len : Int = 1, ?chars : String ) : String {
		var n : Null<Int> = null;
		if( chars == null ) {
			chars = CHARS;
			n = CHARS.length-2;
		} else
			n = chars.length;
		var s = "";
		for( i in 0...len )
			s += chars.charAt( Std.random( n ) );
		return s;
	}
	
}
