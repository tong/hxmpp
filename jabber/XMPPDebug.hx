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
#elseif flash
import flash.external.ExternalInterface;
#end

#if XMPP_DEBUG
		
/**
	Utility for debugging XMPP transfer.<br/>
*/
class XMPPDebug {
	
	#if (flash||js)
	static var firebug : Bool;
	#end
	
	static function __init__() {
		#if js
		try {
			firebug = untyped console != null && console.error != null;
		} catch( e : Dynamic ) {
			firebug = false;
		}
		#elseif flash
		firebug = if( ExternalInterface.available &&
					  ExternalInterface.call( "console.error.toString" ) != null )
			true else false;
		#end
	}
	
	public static function inc( t : String ) {
		#if flash
        if( firebug ) {
        	ExternalInterface.call( "console."+"log", "XMPP-I "+t );
        } else {
			haxe.Log.trace( t, { 
				className : "",
				methodName : "",
				fileName : "XMPP-I",
				lineNumber : 0,
				customParams : []
		    } );
        }
        #elseif (cpp||neko||php)
        print( t, 34, 42 );
        #end
	}
	
	public static function out( t : String ) {
        #if flash
        if( firebug ) {
			ExternalInterface.call( "console."+"log", "XMPP-O "+t );
		} else {
        	haxe.Log.trace( t, { 
	            className : "",
	            methodName : "",
	            fileName : "XMPP-O",
	            lineNumber : 0,
	            customParams : []
	        } );
        }
        #elseif (cpp||neko||php)
        print( t, 34, 43 );
        #end
	}
	
	public static inline function error( t : String ) {
		#if (cpp||neko||php)
        print( t, 30, 42 );
        #end
	}
	
	#if (cpp||neko||php)
	
	public static var defaultColor = 37;
	public static var defaultBackgroundcolor = 44;
	
	static function print( t : String, color : Int, backgroundColor : Int ) {
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
		
	#end
	
}

#end
