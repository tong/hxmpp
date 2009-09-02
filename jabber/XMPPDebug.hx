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

#if (neko||php||cpp)
import util.TerminalUtil;
#end
#if neko
import neko.Lib;
#elseif php
import php.Lib;
#elseif cpp
import cpp.Lib;
#end

//	TODO move util.CL into here

/**
	
	Utility for debugging XMPP transfer.<br>
	For terminal targets you might want to set colors before using since they might differ.
*/
class XMPPDebug {
	
	public static function redirectTraces() {
		#if (flash||js)
		if( haxe.Firebug.detect() ) haxe.Firebug.redirectTraces();
		#end
	}
	
	#if (flash||js)
	
	public static inline function incoming( t : String ) {
		haxe.Log.trace( "IN: "+t );
	}
	
	public static inline function outgoing( t : String ) {
		haxe.Log.trace( "OUT: "+t );
	}
	
	public static inline function error( t : String ) {
		haxe.Log.trace( "XMPP ERROR: "+t );
	}
	
	#elseif (neko||php||cpp)
	
	public static var COLOR_XMPP_IN = { fg : TerminalUtil.BLACK, bg : TerminalUtil.BG_CYAN };
	public static var COLOR_XMPP_OUT = { fg : TerminalUtil.BLACK, bg : TerminalUtil.BG_ORANGE };
	public static var COLOR_XMPP_ERROR = { fg : TerminalUtil.BLACK, bg : TerminalUtil.BG_RED };
	
	public static function print( t : String, ?colors : TerminalColor ) {
		#if cpp
		cpp.Lib.print( t+"\n" );
		#else
		TerminalUtil.print( t+"\n", if( colors != null ) colors.fg, if( colors != null ) colors.bg );
		#end
	}
	
	public static inline function incoming( t : String ) {
		print( t, COLOR_XMPP_IN );
	}
	
	public static inline function outgoing( t : String ) {
		print( t, COLOR_XMPP_OUT );
	}
	
	public static inline function error( t : String ) {
		print( t, COLOR_XMPP_ERROR );
	}
	
	#end
	
}
