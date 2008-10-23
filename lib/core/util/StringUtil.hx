package util;


class StringUtil {
	
	public static var BASE64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
	
	/**
		Creates a random string of given length.
	*/
	public static function random64( ?length : Int = 1 ) : String {
		if( length < 1 ) throw "Out of bound";
		var buf = new StringBuf();
		for( i in 0...length ) {
			buf.add( BASE64.charAt( Std.int( Math.random() * BASE64.length ) ) );
		}
		return buf.toString();
	}
	
	
	/*
	public static inline function getFileExtension( s : String ) : String {
		return s.substr( s.lastIndexOf( "." ) );
	}
	*/
	
}
