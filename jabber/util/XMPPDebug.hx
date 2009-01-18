
// #if JABBER_DEBUG

package jabber.util;


class XMPPDebug {
	
	public static function redirectTraces() {
		#if neko
		if( neko.Web.isModNeko ) {
			haxe.Firebug.redirectTraces();
		} else {
			if( neko.Sys.systemName() == "Linux" ) {
				haxe.Log.trace = myTrace;
			}
		}
		#elseif php
		if( !php.Lib.isCli() ) haxe.Firebug.redirectTraces();
		else haxe.Log.trace = myTrace;
		#else
		if( haxe.Firebug.detect() ) haxe.Firebug.redirectTraces();
		#end
	}
	
	
	#if neko
	
	//TODO send color value to ndll
	//public static var WHITE = 33; 
	//public static var WHITE = 33; 
	//public static var WHITE = 33; 
	
	static var printC = neko.Lib.load( "hxmpp_debug", "printC", 2 );
	
	static function myTrace( v : Dynamic, ?inf : haxe.PosInfos ) {
		var c = 0;
		var buf = new StringBuf();
		if( inf.customParams == null ) {
			buf.add( "\t" );
			buf.add( inf.className+" "+inf.lineNumber );
			buf.add( " => " );
			buf.add( v );
		} else {
			if( inf.customParams[0] == "xmpp-i" ) c = 1;
			else if( inf.customParams[0] == "xmpp-o" ) c = 2;
			buf.add( v );
		}
		buf.add( "\n" );
		printC( untyped buf.toString().__s, c );
    }
	
	#elseif php
	
	static function myTrace( v : Dynamic, ?inf : haxe.PosInfos ) {
		 //echo -e '\E[30;41mblack on red'
		 php.Lib.print( inf.lineNumber+"\t"+v+"\n" );
	}
	
	#end // neko
	
}

//#end // JABBER_DEBUG
