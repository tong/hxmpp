package util;


class StringUtil {
	
	
	/**
		Creates a random (base64 encoded) string of given length.
	*/
	public static function random64( ?len : Int = 1 ) : String {
		if( len < 1 ) throw "Out of bound";
		var b = new StringBuf();
		var len64 = Base64.CHARS.length;
		for( i in 0...len ) {
			b.add( Base64.CHARS.charAt( Std.int( Math.random() * len64 ) ) );
		}
		return b.toString();
	}
	
	
	/*
	public static inline function getFileExtension( s : String ) : String {
		return s.substr( s.lastIndexOf( "." ) );
	}
	*/
	
	
	/*
	public static function hexTable( bytes : haxe.io.Bytes ) : String {
		var b = new StringBuf();
		var i = new haxe.io.BytesInput( bytes );
		for( l in 1...bytes.getData().length+1 ) {
			b.add( "0x" );
			b.add( StringTools.hex( i.readByte() ) );
			if( l%4 == 0 ) b.add( " | " );
			b.add( " " );
			if( l%16 == 0 ) b.add( "\n" );
		}
		return b.toString();
	}
	*/
}
