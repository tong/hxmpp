package util;


class StringUtil {
	
	
	/**
		Creates a random string of given length.
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
	
}
