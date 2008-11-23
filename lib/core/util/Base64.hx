package util;


/**
	Base64 utility.
*/
class Base64 {
	
	public static var CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	
	public static inline function fillNullbits( s : String ) : String {
		while( s.length % 3 != 0 ) s += "=";
		return s;
	}
	
	public static inline function removeNullbits( s : String ) : String {
		while( s.charAt( s.length-1 ) == "=" ) s = s.substr( 0, s.length-1 );
		return s;
	}
	
	
	public static inline function encode( t : String ) : String {
		var c = haxe.BaseCode.encode( t, CHARS );
		c = fillNullbits( c );
		return c;
	}
	
	public static function decode( t : String ) : String {
		var s = removeNullbits( t );
		s = haxe.BaseCode.decode( s, CHARS );
		return s;
	}
	
	
/*
    public static function encode( inp : String ) {
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

    public static function decode( inp : String ) {
    	
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

    static function utf8_encode( string : String ) {
		var r = ~/\r\n/g;
        string = r.replace(string,"\n");
        var utftext:String = "";
		var n:Int = 0;
        while (n < string.length) {
            var c = string.charCodeAt(n);
            if (c < 128) {
                utftext += String.fromCharCode(c);
            }
            else if((c > 127) && (c < 2048)) {
                utftext += String.fromCharCode((c >> 6) | 192);
                utftext += String.fromCharCode((c & 63) | 128);
            }
            else {
                utftext += String.fromCharCode((c >> 12) | 224);
                utftext += String.fromCharCode(((c >> 6) & 63) | 128);
                utftext += String.fromCharCode((c & 63) | 128);
            }
			n++;
        }
        return utftext;
    }

    static function utf8_decode( utftext : String ) {
        var string = "";
        var i : Int = 0;
        var c : Int = 0;
 		var c1 : Int = 0;
		var c2 : Int = 0;
		var c3 : Int = 0;
        while ( i < utftext.length ) {
            c = utftext.charCodeAt( i );
            if( c < 128 ) {
                string += String.fromCharCode( c );
                i++;
            } else if( ( c > 191 ) && ( c < 224 ) ) {
                c2 = utftext.charCodeAt( i+1 );
                string += String.fromCharCode( ( ( c & 31 ) << 6 ) | ( c2 & 63 ) );
                i += 2;
            } else {
                c2 = utftext.charCodeAt( i+1 );
                c3 = utftext.charCodeAt( i+2 );
                string += String.fromCharCode( ( ( c & 15 ) << 12 ) | ( ( c2 & 63 ) << 6 ) | ( c3 & 63 ) );
                i += 3;
            }
        }
        return string;
    }
*/

}
