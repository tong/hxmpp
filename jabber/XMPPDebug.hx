/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber;

import jabber.util.DateUtil;
#if (flash&&!air)
import flash.external.ExternalInterface;
#elseif nodejs
import js.Node;
#elseif rhino
import js.Lib;
#end
import jabber.util.XMLBeautify;

import haxe.macro.Context; //TODO rem

/**
	Utility for debugging XMPP transfer.
	Set the compiler flag: -D xmpp_debug to activate it.
	
	* Terminal targets: Color highlighted
	* Browser targets: Printed to the default debug console
	* Adobe air: Printed to fdb 'trace'
*/
@:require(xmpp_debug)
class XMPPDebug {
	
	static function __init__() {
		//numPrinted = numPrintedIncoming = numPrintedOutgoing = 0;
		#if (flash||js)
			#if (air||nodejs||rhino)
			#else
				#if flash
				useConsole = ExternalInterface.available; // && ExternalInterface.call( "console.error.toString" ) != null );
				#elseif js
				try useConsole = untyped console != null && console.error != null catch( e : Dynamic ) {
					trace(e,"warn");
					useConsole = false;
				}
				#end
			#end
		#end
	}
	
	// TODO use macro for output calls
	/*
	macro public static function debug( t : String ) {
		//return Context.makeExpr( f, Context.currentPos() );
	}
	*/
	
	//public static var numPrinted(getNumPrinted,null) : Int;
	//public static var numPrinted(default,null) : Int;
	//public static var numPrintedIncoming(default,null) : Int;
	//public static var numPrintedOutgoing(default,null) : Int;

	/**
		Activate/Deactivate output.
		Default is true.
	*/
	public static var active = true;
	
	/** */
	public static var lastPrintWasOutgoing(default,null) : Bool = false;
	
	/**
		Indicates if the XMPP debug output should get formatted/beautified.
		Mind: If active, it is not ensured that the formatted string matches exactly the sent/recieved ones!
		Default value is false.
		Currently only supported in terminal targets.
	*/
	public static var beautify : Bool = true;
	
	/**
		Toggle print the current date in meta information
	*/
	public static var showDate : Bool = false;
	
	/**
		Toggle print the current time in meta information
	*/
	public static var showTime : Bool = true;
	
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
	
	//public static inline function printXml( x : Xml )
	//public static inline function printXMPPPacket( p : xmpp.Packet )
	//public static inline function printInfoString( p : xmpp.Packet )
	
	/**
		Print manually to console
	*/
	public static function print( t : String, out : Bool, level : String = "log" ) {
		if( !active )
			return;
			
		#if xmpp_console
		XMPPConsole.printXMPP( t, out );
		
		#else
			#if (sys||nodejs||air||rhino)
			__print( beautify ? XMLBeautify.it(t) : t+"\n", out ? color_out : color_inc );
			#elseif (js||flash)
			__print( beautify ? XMLBeautify.it(t) : t, out, level );
			#end
		#end
	}
	
	#if (sys||nodejs||air||rhino)
	
	public static var color_out = 36;
	public static var color_inc = 33;
	
	/**
	*/
	public static function __print( t : String, color : Int = -1 ) {
		if( color == -1 ) {
			#if rhino
			Lib._print( t );
			#elseif (air&&flash)
			untyped __global__['trace']( t );
			#elseif (air&&js)
			untyped air.trace(t);
			#elseif nodejs
			Node.console.log( t );
			#elseif
			Sys.print( t );
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
		#elseif nodejs
		Node.console.log( b.toString() );
		#else
		Sys.print( b.toString() );
		#end
	}
	
	
	#elseif (js||flash)
	
	/** Indicates if the XMPP transfer should get printed to the browser console */
	public static var useConsole : Bool;
	
	public static var prefixClient = "client";
	public static var prefixServer = "server";

	static var currentGroup : String;
	
	public static function __print( t : String, out : Bool = true, level : String = "log" ) {
		//var num = out ? numPrintedOutgoing++ : numPrintedIncoming++;
		
		#if air
		var info = out ? ">>> xmpp >>>" : "<<< xmpp <<< "; // )+" ("+num+":"+(++numPrinted)+")";
		haxe.Log.trace( t, { className : "", methodName : "", fileName : info, lineNumber : t.length, customParams : [] } );
		
		#else
		if( useConsole ) {
			if( currentGroup == null ) {
				__console( "group", currentGroup = createMetaInformationString( out ) );
			} else {
				if( out && !lastPrintWasOutgoing || !out && lastPrintWasOutgoing ) {
					__console( "groupEnd" );
					//__console( "group", currentGroup = "xmpp "+(out?prefixClient:prefixServer) );
					__console( "group", currentGroup = createMetaInformationString( out ) );
				}
			}
			__console( level, t );
		} else {
			var info = out ? ">>> xmpp >>>" : "<<< xmpp <<< ";
			haxe.Log.trace( t, { className : "", methodName : "", fileName : info, lineNumber : t.length, customParams : [] } );
		}
		#end
		
		lastPrintWasOutgoing = out;
	}
	
	static function createMetaInformationString( out : Bool ) : String {
		var t = "xmpp "+( out ? prefixClient : prefixServer );
		var n = Date.now();
		if( showDate ) {
			var s = DateUtil.formatTimePartValue( n.getDate() )
				+"-"+DateUtil.formatTimePartValue( n.getMonth()+1 );
			t += " ("+s;
			if( !showTime ) t += ")";
		}
		//TODO show ms
		if( showTime ) {
			var s = DateUtil.formatTimePartValue( n.getHours() )
				+":"+DateUtil.formatTimePartValue( n.getMinutes() )
				+":"+DateUtil.formatTimePartValue( n.getSeconds() );
			t += " ";
			if( !showDate ) t += "(";
			t += s+")";
		}
		return t;
	}
	
	/*
	static function __printConsoleGroup( t : String, group : String, level : String ) {
		__console( "group", group );
		__console( level, t );
		__console( "groupEnd" );
	}
	*/

	static inline function __console( c : String, ?t : Dynamic ) {
		#if js
		untyped console[c]( t );
		#elseif flash
		ExternalInterface.call( "console."+c, t );
		#end
	}
	
	#end // (flash||js)
	
}
