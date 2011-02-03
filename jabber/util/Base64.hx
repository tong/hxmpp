/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
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
	
	public static var CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
	
	#if (neko||cpp||js||flash||xmldoc)
	#if !nodejs
	
	static var bc = new BaseCode( Bytes.ofString( CHARS ) );
	
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
	
	#end // !nodejs
	#end // neko||cpp||js||flash||xmldoc
	
	public static #if (nodejs) inline #end
	function encode( t : String ) : String {
		#if php
		return untyped __call__( "base64_encode", t );
		#elseif nodejs
		return Node.newBuffer(t).toString( Node.BASE64 );
		#else
		return fillNullbits( bc.encodeString( t ) );
		#end
	}
	
	public static #if (nodejs) inline #end
	function decode( t : String ) : String {
		#if php
		return untyped __call__( "base64_decode", t );
		#elseif nodejs
		return Node.newBuffer( t, Node.BASE64 ).toString( Node.ASCII );
		#else
		return bc.decodeString( removeNullbits( t ) );
		#end
	}
	
	public static #if (nodejs) inline #end
	function encodeBytes( b : Bytes ) : String {
		#if php
		return untyped __call__( "base64_encode", b.getData() );
		#elseif nodejs
		return b.getData().toString( Node.BASE64 );
		#else
		return fillNullbits( bc.encodeBytes( b ).toString() );
		#end
	}
	
	public static #if (nodejs) inline #end
	function decodeBytes( t : String ) : Bytes {
		#if php
		return Bytes.ofString( untyped __call__( "base64_decode", t ) );
		#elseif nodejs
		return Bytes.ofData( Node.newBuffer( t, Node.BASE64 ) );
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
