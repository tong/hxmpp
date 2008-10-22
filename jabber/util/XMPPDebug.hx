package jabber.util;


class XMPPDebug {
	
	public static function redirectTraces() {
		#if neko
		if( neko.Web.isModNeko ) {
			haxe.Firebug.redirectTraces();
		} else {
			trace( neko.Sys.systemName() );
			if( neko.Sys.systemName() == "Linux" ) {
				haxe.Log.trace = myTrace;
			}
		}
		#else
		haxe.Firebug.redirectTraces();
		#end
	}
	
	
	#if neko
	
	static var printC = neko.Lib.load( "hxmpp_debug", "printC", 2 );
	
	static function myTrace( v : Dynamic, ?inf : haxe.PosInfos ) {
		var c = 0;
		var buf = new StringBuf();
		if( inf.customParams == null ) {
			buf.add( "\t" );
			buf.add( v );
			buf.add( " / " );
			buf.add( inf.className+" / "+inf.lineNumber+"   " );
			
		} else {
			if( inf.customParams[0] ) {
				c = 1;
			} else {
				c = 2;
			}
			buf.add( v );
		}
		buf.add( "\n" );
        //neko.Lib.print( buf.toString() );
		printC( untyped buf.toString().__s, c );
    }

	#end
	
}
