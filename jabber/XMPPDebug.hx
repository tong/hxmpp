package jabber;

#if (neko||php)
import util.CL;
#end
#if neko
import neko.Lib;
#elseif php
import php.Lib;
#end

/**
*/
class XMPPDebug {
	
	public static function redirectTraces() {
		#if (flash||js)
		haxe.Firebug.redirectTraces();
		#end
	}
	
	#if (flash||js)
	
	public static function incoming( t : String ) {
		haxe.Log.trace( "IN: "+t );
	}
	
	public static function outgoing( t : String ) {
		haxe.Log.trace( "OUT: "+t );
	}
	
	#elseif (neko||php)
	
	public static var COLOR_XMPP_INCOMING = { fg : CL.BLACK, bg : CL.BG_CYAN };
	public static var COLOR_XMPP_OUTGOING = { fg : CL.BLACK, bg : CL.BG_ORANGE };
	//public static var COLOR_XMPP_ERROR = { fg : CL.BLACK, bg : CL.BG_RED };
	//public static var ERROR = { fg : CL.WHITE, bg : CL.BG_RED };
	
	public static function print( t : String, ?colors : CommandLineColors ) {
		CL.print( t+"\n", if( colors != null ) colors.fg, if( colors != null ) colors.bg );
	}
	
	public static inline function incoming( t : String ) {
		print( t, COLOR_XMPP_INCOMING );
	}
	
	public static inline function outgoing( t : String ) {
		print( t, COLOR_XMPP_OUTGOING );
	}
	
	#end
	
}
