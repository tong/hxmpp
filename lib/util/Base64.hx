package util;

/**
	Base64 utility.
*/
class Base64 {
	
	public static var CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	
	public static function fillNullbits( s : String ) : String {
		while( s.length % 3 != 0 )
			s += "=";
		return s;
	}
	
	public static function removeNullbits( s : String ) : String {
		while( s.charAt( s.length-1 ) == "=" )
			s = s.substr( 0, s.length-1 );
		return s;
	}
	
	public static inline function encode( t : String ) : String {
		return fillNullbits( haxe.BaseCode.encode( t, CHARS ) );
	}
	
	public static inline function decode( t : String ) : String {
		return haxe.BaseCode.decode( removeNullbits( t ), CHARS );
	}
	
	/**
		Creates a random (base64 encoded) string of given length.
	*/
	public static function random( ?len : Int = 1 ) : String {
		if( len < 1 )
			throw "Invalid length";
		#if (neko||cpp)
		var b = new StringBuf();
		for( i in 0...len )
			b.add( CHARS.charAt( Std.int( Math.random()*64 ) ) );
		return b.toString();
		#else
		var t = "";
		for( i in 0...len )
			t += CHARS.charAt( Std.int( Math.random()*64 ) );
		return t;
		#end
		
	}
	
/*
    public static function _encode( inp : String ) {
		var out = "";
		var c1 : Int;
		var c2 : Null<Int>;
		var c3 : Null<Int>;
		var enc1 : Int;
		var enc2 : Int;
		var enc3 : Int;
		var enc4 : Int;
		var i : Int = 0;
        inp = Base64.utf8_encode( inp );
		while( i < inp.length ) {
			c1 = inp.charCodeAt( i++ );
			c2 = inp.charCodeAt( i++ );
			c3 = inp.charCodeAt( i++ );
			enc1 = c1 >> 2;
			enc2 = ( ( c1 & 3 ) << 4 ) | ( c2 >> 4 );
			enc3 = ( ( c2 & 15 ) << 2 ) | ( c3 >> 6 );
			enc4 = c3 & 63;
			if( c2 == null) enc3 = enc4 = 64;
            else if( c3 == null ) enc4 = 64;
            out += str.charAt( enc1 ) + str.charAt( enc2 ) +
            	   str.charAt( enc3 ) + str.charAt( enc4 );
        }
        return out;
    }

    public static function _decode( inp : String ) {
        var out : String = "";
        var c1 : Int;
		var c2 : Int;
		var c3 : Int;
		var enc1 : Int;
		var enc2 : Int;
		var enc3 : Int;
		var enc4 : Int;
		var i : Int = 0;
		var r = ~/[^A-Za-z0-9\+\/\=]/g;
        inp = r.replace( inp,  "" );
        while( i < inp.length ) {
            enc1 = str.indexOf( inp.charAt( i++ ) );
            enc2 = str.indexOf( inp.charAt( i++ ) );
            enc3 = str.indexOf( inp.charAt( i++ ) );
            enc4 = str.indexOf( inp.charAt( i++ ) );
            c1 = ( enc1 << 2 ) | ( enc2 >> 4 );
            c2 = ( ( enc2 & 15 ) << 4 ) | ( enc3 >> 2 );
            c3 = ( ( enc3 & 3 ) << 6 ) | enc4;
            out += String.fromCharCode( c1 );
            if( enc3 != 64 ) out += String.fromCharCode( c2 );
            if( enc4 != 64 ) out += String.fromCharCode( c3 );
        }
        out = Base64.utf8_decode( out );
        return out;
    }
*/

}
