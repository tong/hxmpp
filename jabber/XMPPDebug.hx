package jabber;

#if (neko||php||cpp)
import util.CL;
#end
#if neko
import neko.Lib;
#elseif php
import php.Lib;
#end

/**
	Utility for debugging XMPP transfer.
	For terminal targets you might want to set colors before using.
*/
class XMPPDebug {
	
	public static function redirectTraces() {
		#if (flash||js)
		haxe.Firebug.redirectTraces();
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
	
	public static var COLOR_XMPP_IN = { fg : CL.BLACK, bg : CL.BG_CYAN };
	public static var COLOR_XMPP_OUT = { fg : CL.BLACK, bg : CL.BG_ORANGE };
	public static var COLOR_XMPP_ERROR = { fg : CL.BLACK, bg : CL.BG_RED };
	
	public static function print( t : String, ?colors : TerminalColor ) {
		CL.print( t+"\n", if( colors != null ) colors.fg, if( colors != null ) colors.bg );
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
