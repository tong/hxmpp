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
	<p>
	Utility for debugging XMPP transfer.<br/>
	Set the haXe compiler flag: -D XMPP_DEBUG to activate it.
	</p>
	<p>
	XMPP transfer display gets relayed to the default debug console on browser targets (if available),
	highlighted on terminal targets.
	</p>
	<p>
	</p>
*/
class XMPPDebug {
	
	#if (flash&&JABBER_CONSOLE) //HACK TODO
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
			if( stream != null )
				return stream.sendData( t );
			return null;
		} );
		#end
		#elseif js
		try {
			useConsole = untyped console != null && console.error != null;
		} catch( e : Dynamic ) {
			useConsole = false;
		}
		#end
	}
	#end
	
	public static function inc( t : String ) {
		#if JABBER_CONSOLE
		printToXMPPConsole( t, false );
		#end
		_inc(t);
	}

	public static function out( t : String ) {
		#if JABBER_CONSOLE
		printToXMPPConsole( t, true );
		#end
		_out(t);
	}
	
	#if JABBER_CONSOLE
	static function printToXMPPConsole( t : String, out : Bool ) {
	var v = haxe.Serializer.run( t );
		try {
			#if flash
			ExternalInterface.call( 'hxmpp.Console.print("'+v+'",'+out+')' );
			#elseif js
			untyped hxmpp.Console.print( v, out );
			#end
		} catch( e : Dynamic ) {
			trace( "HXMPP.console debugging error: "+e, "warn" );
		}
	}
	#end
	
	/*
	public static inline function info( t : String ) {
		handler.out( t );
	}
	*/
	
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
	
	/*
	public static inline function error( t : String ) {
	}
	*/
	
	public static function print( t : String, out : Bool, level : String = "log" ) {
		#if (flash||js)
		_print( t, out, level );
		#elseif (cpp||neko||php)
		_print( t, (out)?fgOut:fgInc, (out)?bgOut:bgInc );
		#end
	}
	
	#if (flash||js)
	
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
	
	public static function _print( t : String, color : Int, backgroundColor : Int ) {
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
