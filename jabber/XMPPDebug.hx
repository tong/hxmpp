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
#elseif nodejs
import js.Lib;
#elseif flash
import flash.external.ExternalInterface;
#end

#if JABBER_CONSOLE
typedef TStream = {
	var jidstr : String;
}
#end

/**
	<p>
	Utility for debugging XMPP transfer.<br/>
	Set the haXe compiler flag: -D XMPP_DEBUG to activate it.
	</p>
	<p>
	Displayed XMPP transfer gets relayed to the default debug console on browser targets,
	color highlighted on terminal targets.
	</p>
*/
class XMPPDebug {
	
	#if (JABBER_CONSOLE&&flash) //HACK TODO
	public static var stream : Stream;
	#end
	
	#if (flash||js)
	
	static function __init__() {
		#if flash
		useConsole = ( ExternalInterface.available &&
					   ExternalInterface.call( "console.error.toString" ) != null );
		#if JABBER_CONSOLE
		if( !ExternalInterface.available ) {
			trace( "Unable to init HXMPP.console, external interface not available", "warn" );
			return;
		}
		ExternalInterface.addCallback( "sendData", function(t:String){
			if( stream == null )
				return null;
			return stream.sendData( t );
		} );
		#end
		#elseif (js&&!nodejs)
		#if air
		useConsole = false;
		#else
		try {
			useConsole = untyped console != null && console.error != null;
		} catch( e : Dynamic ) {
			useConsole = false;
		}
		#end
		#end
	}
	
	#end // (flash||js)
	
	public static inline function inc( t : String ) {
		#if JABBER_CONSOLE
		printToXMPPConsole( t, false );
		#end
		_inc(t);
	}

	public static inline function out( t : String ) {
		#if JABBER_CONSOLE
		printToXMPPConsole( t, true );
		#end
		_out(t);
	}
	
	#if JABBER_CONSOLE
	static function printToXMPPConsole( t : String, out : Bool ) {
		try {
			#if flash
			ExternalInterface.call( 'XMPPConsole.print("'+t+'",'+out+')' );
			#elseif js
			untyped XMPPConsole.print( t, out );
			#end
		} catch( e : Dynamic ) {
			trace( "HXMPP.console error: "+e, "warn" );
		}
	}
	#end
	
	/**
		Default incoming XMPP debug relay.
	*/
	public static inline function _inc( t : String ) {
		print( t, false, "log" );
	}
	
	/**
		Default outgoing XMPP debug relay.
	*/
	public static inline function _out( t : String ) {
		print( t, true, "log" );
	}
	
	public static inline function print( t : String, out : Bool, level : String = "log" ) {
		#if (neko||cpp||php||nodejs)
		_print( t, out ? color_out : color_inc );
		#elseif (flash||js)
		_print( t, out, level );
		#end
	}
	
	#if (neko||cpp||php||nodejs)

	public static var color_out = 36;
	public static var color_inc = 33;
	
	public static function _print( t : String, color : Int ) {
		if( color == null ) {
			Lib.print( t );
			return;
		}
		var b = new StringBuf();
		b.add( "\033[" );
		b.add( color );
		b.add( "m" );
		b.add( t );
		b.add( "\033[" );
		b.add( "m\n" );
		Lib.print( b.toString() );
	}
	
	#elseif (flash||js)
	
	/** Indicates if the transfer should get printed to the browsers debug console */
	public static var useConsole : Bool;
	
	public static function _print( t : String, out : Bool = true, level : String = "log" ) {
		var dir = "XMPP-"+((out)?"O ":"I ");
		if( useConsole ) {
			#if flash
			ExternalInterface.call( "console."+level, dir+t );
			#else
			untyped console[level]( dir+t );
			#end
		} else {
			haxe.Log.trace( t, { className : "", methodName : "", fileName : dir, lineNumber : 0, customParams : [] } );
		}
	}
	
	#end // (flash!!js)
	
}

#end // XMPP_DEBUG
