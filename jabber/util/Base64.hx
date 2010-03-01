package jabber.util;

/**
	Base64 utility.
*/
class Base64 {
	
	static function __init__() {
		//TODO hmm?
		//%:";
		//'+/='
		//'-_.'
		CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
		/*
		#if js
		byteToCharMap = new Array();
		charToByteMap = new Array();
		// quick mappings back and forth ... precompute two maps.
		for( i in 0...CHARS.length )
			charToByteMap[untyped byteToCharMap[i] = CHARS.charAt( i )] = i;
		#else
		#end
		*/
		bc = new haxe.BaseCode( haxe.io.Bytes.ofString( CHARS ) );
	}
	
	//static var inst : Base64;
	
	public static var CHARS(default,null) : String;
	public static var bc(default,null) : haxe.BaseCode;
	
	/**
	*/
	public static function fillNullbits( s : String ) : String {
		/*
		var n = (s.length)%3;
		if( n == 0 ) n -= 1;
		for( i in 0...n ) s += "=";
		*/
		var n = (s.length)%3;
		n = ( n == 0 ) ? ((s.length-1)%3) : ((s.length)%3+1);
		for( i in 0...n ) s += "=";
		return s;
	}
	
	/**
	*/
	public static function removeNullbits( s : String ) : String {
		while( s.charAt( s.length-1 ) == "=" ) s = s.substr( 0, s.length-1 );
		return s;
	}
	
	/**
	*/
	public static function encode( t : String ) : String {
		return fillNullbits( bc.encodeString( t ) );
	}
	
	/**
	*/
	public static function decode( t : String ) : String {
		return bc.decodeString( removeNullbits( t ) );
	}
	
	/*
	#if js
	
	static var byteToCharMap : Array<String>;
	static var charToByteMap : Array<Int>;

	public static function encodeByteArray( t : Array<Int> ) : String {
		var s = new Array<String>();
		var i = 0;
		while( i < t.length ) {
			var b1 = t[i];
			var haveB2 = i+1 < t.length;
			var b2 = haveB2 ? t[i+1] : 0;
			var haveB3 = i + 2 < t.length;
			var b3 = haveB3 ? t[i+2] : 0;
			var ob1 = b1 >> 2;
			var ob2 = ((b1 & 0x03) << 4) | (b2 >> 4);
		    var ob3 = ((b2 & 0x0F) << 2) | (b3 >> 6);
			var ob4 = b3 & 0x3F;
			if( !haveB3 ) {
				ob4 = 64;
				if( !haveB2 ) ob3 = 64;
			}
			s.push( byteToCharMap[ob1] );
			s.push( byteToCharMap[ob2] );
			s.push( byteToCharMap[ob3] );
			s.push( byteToCharMap[ob4] );
			i += 3;
		}
		return s.join( '' );
	}
	
	public static function decodeStringToByteArray( t : String ) : Array<Int> {
		if( t.length % 4 != 0 )
			throw 'Length of b64-encoded data must be zero mod four';
		var a = new Array<Int>();
		var i = 0;
		while( i < t.length ) {
			var b1 = untyped charToByteMap[t.charAt(i)];
			var b2 = untyped charToByteMap[t.charAt(i+1)];
			var b3 = untyped charToByteMap[t.charAt(i+2)];
			var b4 = untyped charToByteMap[t.charAt(i+3)];
			if( b1 == null || b2 == null || b3 == null || b4 == null )
				throw "Base64 decoding error";
			a.push( (b1<<2)|(b2>>4) );
			if( b3 != 64 ) {
				a.push( ((b2<<4) & 0xF0) | (b3>>2) );
				if( b4 != 64 )
					a.push( ((b3<<6) & 0xC0) | b4 );
			}
			i += 4;
		}
		return a;
	}
	
	#end // js
	*/
	
	//TODO
	/**
		Creates a random string of given length.
	*/
	public static function random( ?len : Int = 1 ) : String {
		var b = new StringBuf();
		var bits = 0;
		var bitcount = 0;
		var i = 0;
		while( i < len ) {
			//if( bitcount < 6 ) {
			bits = Std.int( Math.random()*CHARS.length);//Math.POSITIVE_INFINITY);
				//bitcount = 32;
			//}
			b.add( CHARS.charAt(bits&0x3F));
			bits >>= 6;
			bitcount -= 6;
			i++;
		}
		return b.toString();
	}

}
