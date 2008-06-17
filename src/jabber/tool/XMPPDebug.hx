package jabber.tool;

#if flash9
import flash.text.TextField;
import flash.text.TextFormat;
#end


/**
	flash9, neko, js, (flash).
*/
class XMPPDebug {
	
	public static var COLOR_INFO 		= 0x000000;
	public static var COLOR_XMPP_IN		= 0x0000ff;
	public static var COLOR_XMPP_OUT 	= 0xff0000;
	
    public static function setRedirection() {
		haxe.Log.trace = myTrace;
    }
 
    static function myTrace( v : Dynamic, ?inf : haxe.PosInfos ) {
    	
    	#if js
    	haxe.Firebug.trace( v, inf );
    	
    	#else neko
    	/*
    	var out = v;
    	if( inf.customParams != null ) {
    		out += inf.className + ":" + inf.lineNumber + ":" +  v;
    	}
    	neko.Lib.print( out + "\n\n"  );
    	*/
    	neko.Lib.print( v + "\n\n"  );
    	
    	#else flash9
    	XMPPDebug.trace( v, inf );
    	
    	#else flash
    	flash.Lib.trace( v );
    	
    	#end
    }
    
    
    //###############################################
    #if flash9 //####################################
    
    public static var w = 1024;
    public static var h = 768;
    public static var fontName = "Arial";
    public static var fontSize = 10;
	public static var history : Array<{s:String,format:TextFormat}>;
	public static var history_length = 300;
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
