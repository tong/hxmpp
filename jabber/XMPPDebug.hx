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
package jabber;

#if neko
import neko.Lib;
#elseif php
import php.Lib;
#elseif cpp
import cpp.Lib;
#elseif nodejs
import js.Lib;
#elseif (flash&&!air)
import flash.external.ExternalInterface;
#elseif rhino
import js.Lib;
#end
import xmpp.XMLBeautify;

/**
	Utility for debugging XMPP transfer.
	Set the haXe compiler flag: -D XMPP_DEBUG to activate it.
	
	* Terminal targets: Color highlighted
	* Browser targets: Printed to the default debug console
	* Adobe air: Printed to fdb 'trace'
*/
@:require(XMPP_DEBUG) class XMPPDebug {
	
	#if (flash||js)
	static function __init__() {
		#if (air)
		#else
			#if flash
			//useConsole = ( ExternalInterface.available && ExternalInterface.call( "console.error.toString" ) != null );
			useConsole = ExternalInterface.available;
			#elseif js
				#if (nodejs||rhino)
				#else
				try useConsole = untyped console != null && console.error != null catch( e : Dynamic ) {
					useConsole = false;
				}
				#end
			#end
		#end
	}
	#end
	
	/**
		Indicates if the XMPP debug output should get formatted/beautified.
		If active, it is not ensured that the shown string matches the sent/recieved ones.
		Default value is false.
		Currently only supported in terminal targets.
	*/
	public static var beautify = false;
	
	/**
		Print incoming XMPP data
	*/
	public static inline function i( t : String ) {
		print( t, false );
	}
	
	/**
		Print outgoing XMPP data
	*/
	public static inline function o( t : String ) {
		print( t, true );
	}
	
	/**
	*/
	public static inline function print( t : String, out : Bool, level : String = "log" ) {
		#if XMPP_CONSOLE
		XMPPConsole.printXMPP(t,out);
		#else
			#if (neko||cpp||php||air||nodejs||rhino)
			__print( beautify ? XMLBeautify.it(t) : t+"\n", out ? color_out : color_inc );
			#elseif (flash||js)
			__print( beautify ? XMLBeautify.it(t) : t, out, level );
			#end
		#end // XMPP_CONSOLE
	}
	
	#if (neko||cpp||php||air||nodejs||rhino)
	
	public static var color_out = 36;
	public static var color_inc = 33;
	
	public static function __print( t : String, color : Int = -1 ) {
		if( color == -1 ) {
			#if rhino
			Lib._print( t );
			#elseif (air&&flash)
			untyped __global__['trace']( t );
			#elseif (air&&js)
			untyped air.trace(t);
			#else
			Lib.print( t );
			#end
			return;
		}
		var b = new StringBuf();
		b.add( "\033[" );
		b.add( color );
		b.add( "m" );
		b.add( t );
		b.add( "\033[" );
		b.add( "m" );
		#if rhino
		Lib._print( b.toString() );
		#elseif air
			#if flash
			untyped __global__['trace']( b.toString() );
			#else
			untyped air.trace( b.toString() );
			#end
		#else
		Lib.print( b.toString() );
		#end
	}
	
	#elseif (flash||js)
	
	/**
		Indicates if the XMPP transfer should get printed to the browser console
	*/
	public static var useConsole : Bool;
	
	public static function __print( t : String, out : Bool = true, level : String = "log" ) {
		var dir = out ? "=>" : "<=";
		#if air
		haxe.Log.trace( t, { className : "", methodName : "", fileName : "XMPP"+dir, lineNumber : t.length, customParams : [] } );
		#else
		if( useConsole ) {
			#if flash
			ExternalInterface.call( "console."+level, dir+t );
			#else
			untyped console[level]( dir+t );
			#end
		} else {
			haxe.Log.trace( t, { className : "", methodName : "", fileName : "XMPP"+dir, lineNumber : t.length, customParams : [] } );
		}
		#end
	}
	
	#end // (flash||js)
	
}
