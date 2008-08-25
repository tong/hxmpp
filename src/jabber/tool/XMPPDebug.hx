package jabber.tool;

#if flash9
import flash.text.TextField;
import flash.text.TextFormat;
#end



/**
	flash9, neko, js, (flash).
	
	Trace utility for jabber streams.
*/
class XMPPDebug {
	
	public static var COLOR_INFO 	 = 0x222222;
	public static var COLOR_XMPP_IN	 = 0x6CC8EF;
	public static var COLOR_XMPP_OUT = 0xA80080;
	
	
    public static function setRedirection() {
		haxe.Log.trace = myTrace;
    }
 
 
    static function myTrace( v : Dynamic, ?inf : haxe.PosInfos ) {
    	
    	#if js
    	haxe.Firebug.trace( v, inf );
    	
    	#elseif neko
    	/*
    	var out = v;
    	if( inf.customParams != null ) {
    		out += inf.className + ":" + inf.lineNumber + ":" +  v;
    	}
    	neko.Lib.print( out + "\n\n"  );
    	*/
    	
    	if( neko.Web.isModNeko ) {
    		if( haxe.Firebug.detect() ) {
	    		haxe.Firebug.trace( v, inf );
    		}
    		//neko.Lib.println( v );
    		//neko.Lib.println( '<div>'+StringTools.htmlEscape(v)+'</div><br/>' );
    	} else {
	    	neko.Lib.println( v );
    	}
    	
    	#elseif flash9
    	XMPPDebug.trace( v, inf );
    	haxe.Firebug.trace( v, inf );
    	
    	#elseif flash
    	flash.Lib.trace( v );
    	
    	#elseif php
    	php.Lib.println( '<div>'+StringTools.htmlEscape(v)+'</div>' );
    	haxe.Firebug.trace( v, inf );
    	
    	#end
    }
    
    
    #if flash9 //##############
    
    public static var w = 1024;
    public static var h = 600;
    public static var fontName = "Arial";
    public static var fontSize = 10;
	public static var history : Array<{s:String,format:TextFormat}>;
	public static var history_length = 60;
    static var tf : TextField;
    static var textFormatInfo 	 = new TextFormat( fontName, fontSize, COLOR_INFO );
	static var textFormatXMPPIn  = new TextFormat( fontName, fontSize, COLOR_XMPP_IN );
	static var textFormatXMPPOut = new TextFormat( fontName, fontSize, COLOR_XMPP_OUT );
    
    
    static var _ = init();
    static function init() {
		history = new Array();
		tf = new TextField();
		tf.multiline = tf.wordWrap = true;
    	tf.width = w;
    	tf.height = h;
		flash.Lib.current.addChild( tf );
    }  
    
    
    public static function trace( v : Dynamic, ?inf : haxe.PosInfos ) {
    	
    	var out = new String("");
    	var format : TextFormat;
    	if( inf.customParams != null ) {
    		if( inf.customParams[0] ) format = textFormatXMPPIn;
    		else format= textFormatXMPPOut;
    		out = v;
    	} else {
    		format = textFormatInfo;
    		out += inf.className + ":" + inf.lineNumber + ":" +  v;
    	}
    	out += "\n";
    	tf.text += out;
    	
    	if( history.length == history_length ) {
    		history.splice( 0, 1 );
    	}
    	history.push( { s : out, format : format } );
    	
    	// recreate textformats
    	var i = 0;
    	for( l in history ) {
    		var len = l.s.length;
    		tf.setTextFormat( l.format, i, i+len );
    		i += len;
    	}
    	tf.setTextFormat( format, tf.text.length - out.length, tf.text.length );
    }
    
    #end // flash9
    
}
