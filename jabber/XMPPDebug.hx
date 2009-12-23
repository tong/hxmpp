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

#if XMPP_DEBUG

#if neko
import neko.Lib;
#elseif php
import php.Lib;
#elseif cpp
import cpp.Lib;
#elseif flash
import flash.external.ExternalInterface;
#end

/**
	Utility for debugging XMPP transfer.<br/>
	Set the haXe compiler flag: -D XMPP_DEBUG to activate it.
*/
class XMPPDebug {
	
	static var instance = new XMPPDebug();
	
	function new() {
		#if js
		try {
			useConsole = untyped console != null && console.error != null;
		} catch( e : Dynamic ) {
			useConsole = false;
		}
		#elseif flash
		useConsole = ( ExternalInterface.available &&
					   ExternalInterface.call( "console.error.toString" ) != null );
		#end
	}
	
	public static inline function inc( t : String, ?level : String = "log" ) {
		print( t, false, level );
	}
	
	public static inline function out( t : String, ?level : String = "log" ) {
		print( t, true, level );
	}
	
	/*
	public static inline function error( t : String ) {
	}
	*/
	
	public static function print( t : String, out : Bool, level : String = "log" ) {
		#if (flash||js)
		instance._print( t, out, level );
		#elseif (cpp||neko||php)
		instance._print( t, (out)?fgOut:fgInc, (out)?bgOut:bgInc );
		#end
	}
	
	#if (flash||js)
	
	static var useConsole : Bool;
	
	public function _print( t : String, out : Bool = true, level : String = "log" ) {
		var dir = "XMPP-"+((out)?"O ":"I ");
		if( useConsole ) {
			#if flash
			ExternalInterface.call( "console."+level, dir+t );
			#else
			untyped console[level]( dir+t );
			#end
		} else {
			//TODO
			 haxe.Log.trace( t, { className : "", methodName : "", fileName : dir, lineNumber : 0, customParams : [] } );
		}
	}
	
	#elseif (cpp||neko||php)
	
	public static var fgInc = 34;
	public static var bgInc = 42;
	public static var fgOut = 34;
	public static var bgOut = 43;
	public static var defaultColor = 37;
	public static var defaultBackgroundcolor = 44;
	
	public function _print( t : String, color : Int, backgroundColor : Int ) {
		if( color == null ) {
			Lib.print( t );
			return;
		}
		var b = new StringBuf();
		b.add( "\033[" );
		b.add( color );
		if( backgroundColor != -1 ) {
			b.add( ";" );
			b.add( backgroundColor );
		}
		b.add( "m" );
		b.add( t );
		b.add( "\033[" );
		b.add( defaultColor );
		b.add( ";" );
		b.add( defaultBackgroundcolor );
		b.add( "m\n" );
		Lib.print( b.toString() );
	}
	
	#end // (cpp||neko||php)
	
}

#end // XMPP_DEBUG
