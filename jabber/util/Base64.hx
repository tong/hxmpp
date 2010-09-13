package jabber.util;

import haxe.BaseCode;
import haxe.io.Bytes;
#if nodejs
import js.Node;
#end

/**
	Base64 encoding/decoding utility.
*/
class Base64 {
	
	static function __init__() {
		//TODO hmm?
		//%:";
		//'+/='
		//'-_.'
		CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
		#if (neko||cpp||js||swf)
		bc = new BaseCode( Bytes.ofString( CHARS ) );
		#end
	}
	
	public static var CHARS(default,null) : String;
	
	#if (neko||cpp||js||swf)
	#if !nodejs
	
	public static var bc(default,null) : BaseCode;
	
	public static function fillNullbits( s : String ) : String {
		var n = (s.length)%3;
		n = ( n == 0 ) ? ((s.length-1)%3) : ((s.length)%3+1);
		for( i in 0...n ) s += "=";
		return s;
	}
	
	public static function removeNullbits( s : String ) : String {
		while( s.charAt( s.length-1 ) == "=" ) s = s.substr( 0, s.length-1 );
		return s;
	}
	
	#end // neko||cpp||js||swf
	#end // !nodejs
	
	public static function encode( t : String ) : String {
		#if php
		return untyped __call__( "base64_encode", t );
		#elseif nodejs
		return Node.newBuffer(t).toString( Node.BASE64 );
		#else
		return fillNullbits( bc.encodeString( t ) );
		#end
	}
	
	public static function decode( t : String ) : String {
		#if php
		return untyped __call__( "base64_decode", t );
		#elseif nodejs
		return Node.newBuffer( t, Node.BASE64 ).toString( Node.ASCII );
		#else
		return bc.decodeString( removeNullbits( t ) );
		#end
	}
	
	public static function encodeBytes( b : Bytes ) : String {
		#if php
		return untyped __call__( "base64_encode", b.getData() );
		//TODO nodejs native
		#else
		return fillNullbits( bc.encodeBytes( b ).toString() );
		#end
	}
	
	public static function decodeBytes( t : String ) : Bytes {
		#if php
		return haxe.io.Bytes.ofString( untyped __call__( "base64_decode", t ) );
		//TODO nodejs native
		#else
		return bc.decodeBytes( Bytes.ofString( removeNullbits( t ) ) );
		#end
	}
	
	/**
		Create a random string of given length.
	*/
	public static function random( len : Int = 1, ?chars : String ) : String {
		if( chars == null ) chars = CHARS;
		var r = "";
		for( i in 0...len ) r += chars.substr( Math.floor( Math.random()*chars.length ), 1 );
		return r;
	}
	
}
