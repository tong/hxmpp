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
		if( !php.Lib.isCli() ) haxe.Firebug.redirectTraces();
		else haxe.Log.trace = myTrace;
		#else
		if( haxe.Firebug.detect() ) {
			haxe.Firebug.redirectTraces();
		}
		#end
	}
	
	
	#if neko
	
	//TODO
	
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
	
	static function myTrace( v : Dynamic, ?inf : haxe.PosInfos ) {
		 //echo -e '\E[30;41mblack on red'
		 php.Lib.print( inf.lineNumber+"\t"+v+"\n" );
	}
	
	#end
	
}
