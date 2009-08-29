package util;

#if neko
import neko.Lib;
#elseif php
import php.Lib;
#elseif cpp
import cpp.Lib;
#end

typedef TerminalColor = {
	var fg : Int;
	var bg : Int;
}

/**
	Colored bash printing.
*/
class TerminalUtil {
	
	public static inline var GREY = 30;
	public static inline var RED = 31;
	public static inline var CYAN = 32;
	public static inline var ORANGE = 33;
	public static inline var BLACK = 34;
	public static inline var PURPLE = 35;
	public static inline var TURQUOISE = 36;
	public static inline var WHITE = 37;

	public static inline var BG_GREY = 40;
	public static inline var BG_RED = 41;
	public static inline var BG_CYAN = 42;
	public static inline var BG_ORANGE = 43;
	public static inline var BG_BLACK = 44;
	public static inline var BG_5 = 45;
	public static inline var BG_6 = 46;
	public static inline var BG_7 = 47;
	
	public static var defaultColor = WHITE;
	public static var defaultBackgroundcolor = BG_BLACK;
	
	// "\033["+color+"m"+t+"\033[37m"
	/**
		Colored terminal output.
	*/
	public static function print( t : String, ?color : Int = -1, backgroundColor : Int = -1 ) {
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
		b.add( "m" );
		Lib.print( b.toString() );
	}
	
}
