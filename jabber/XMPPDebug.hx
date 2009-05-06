package jabber;


class XMPPDebug {
	
	public static function redirectTraces() {
		#if neko
		if( neko.Web.isModNeko ) {
			haxe.Firebug.redirectTraces();
		} else {
			var sysName = neko.Sys.systemName();
			if( neko.Sys.systemName() != "Linux" ) {
				trace( "XMPPDebug not supported on "+sysName );
				return;
			}
			haxe.Log.trace = myTrace;
		}
		
		#elseif php
		if( !php.Lib.isCli() ) haxe.Firebug.redirectTraces() else haxe.Log.trace = myTrace;
		
		#elseif XMPP_CONSOLE
		haxe.Log.trace = consoleTrace;
		
		#else
		haxe.Firebug.redirectTraces();
		
		#end
	}
	
	/*
	#if XMPP_CONSOLE
	static var console = XMPPConsole.getInstance();
	static function consoleTrace( v : Dynamic, ?inf : haxe.PosInfos ) {
		//haxe.Firebug.trace( v, inf );
		console.transfered( v, inf );
	}
	#end
	*/
	
	#if neko
	
	static var _print = neko.Lib.load( "hxmpp_debug", "printC", 2 );
	
	static function myTrace( v : Dynamic, ?inf : haxe.PosInfos ) {
		var c = 0;
		var b = new StringBuf();
		if( inf.customParams == null ) {
			b.add( "\t" );
			b.add( inf.className+" "+inf.lineNumber );
			b.add( " => " );
			b.add( v );
		} else {
			if( inf.customParams[0] == "xmpp-i" ) c = 1;
			else if( inf.customParams[0] == "xmpp-o" ) c = 2;
			b.add( v );
		}
		b.add( "\n" );
		_print( untyped b.toString().__s, c );
    }
	
	#elseif php
	
	static inline var YELLOW = 33;
	static inline var CYAN = 32;
	static inline var WHITE = 37;
	
	static function myTrace( v : Dynamic, ?inf : haxe.PosInfos ) {
		var t = "";
		if( inf.customParams == null ) {
		 	t += "\t\n";
		 	t += inf.className+" "+inf.lineNumber;
		 	t += " => "+v+"\n";
		} else {
			t += "\n"+v+"\n";
		}
		var c = if( inf.customParams[0] == "xmpp-i" ) YELLOW;
		else if( inf.customParams[0] == "xmpp-o" ) CYAN;
		else WHITE;
		php.Lib.print( "\033["+c+"m"+t+"\033[37m" );
	}
	
	#end
	
}
