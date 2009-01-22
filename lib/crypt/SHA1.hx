package crypt;


class SHA1 {
	
	static inline var hex_chr = "0123456789abcdef";
	
	/**
		Take a string and return the hex representation of its SHA-1.
	*/
	public static  function encode( s : String ) {
		#if neko
			untyped return new String( base_encode( make_sha1( s.__s ), hex_chr.__s ) );
		#elseif flash
			return __jsflash_encode( s );
		#elseif js
			return __jsflash_encode( s );
		#elseif php
			return __jsflash_encode( s );
		//#else error
		#end
	}
	
	#if neko
	static var base_encode = neko.Lib.load( "std", "base_encode", 2 );
	static var make_sha1 = neko.Lib.load( "sha1","make_sha1", 1 );
	#else
	
	
	static function __jsflash_encode( s : String ) : String {
		
		var x = str2blks_SHA1( s );
		var w = new Array<Int>();
	
		var a =  1732584193;
	 	var b = -271733879;
	  	var c = -1732584194;
	  	var d =  271733878;
		var e = -1009589776;
	
		var i = 0;
		while( i < x.length ) {
	    	var olda = a;
	    	var oldb = b;
	    	var oldc = c;
	    	var oldd = d;
	    	var olde = e;
		
			var j = 0;
			while( j < 80 ) {
	      		if(j < 16) w[j] = x[i + j];
	      		else w[j] = rol(w[j-3] ^ w[j-8] ^ w[j-14] ^ w[j-16], 1);
	      		var t = add(add(rol(a, 5), ft(j, b, c, d)), add(add(e, w[j]), kt(j)));
	      		e = d;
	      		d = c;
	      		c = rol(b, 30);
	      		b = a;
	     		a = t;
	      
	      		j++;
	    	}
	    	a = add( a, olda );
	    	b = add( b, oldb );
	    	c = add( c, oldc );
	   	 	d = add( d, oldd );
	   	 	e = add( e, olde );
	    	i += 16;
		}
		return hex(a) + hex(b) + hex(c) + hex(d) + hex(e);
	}
	
	static inline function hex( num : Int ) : String {
		var s = "";
		var j = 7;
		while( j >= 0 ) {
			s += hex_chr.charAt( ( num >> ( j * 4 ) ) & 0x0F );
			j--;
		}
  		return s;
	}

	/**
		Convert a string to a sequence of 16-word blocks, stored as an array.
		Append padding bits and the length, as described in the SHA1 standard.
	*/
	static function str2blks_SHA1( s :String ) : Array<Int> {
		var nblk = ( ( s.length + 8 ) >> 6 ) + 1;
		var blks = new Array();
		var i = 0;
		while( i < nblk*16 ) {
			blks[i] = 0;
			i++;
	  	}
		i = 0;
		while( i < s.length ) {
			blks[i >> 2] |= s.charCodeAt(i) << ( 24 - ( i % 4 ) * 8 );
			i++;
		}
	  	blks[i >> 2] |= 0x80 << ( 24 - ( i % 4 ) * 8 );
	  	blks[nblk * 16 - 1] = s.length * 8;
	  	return blks;
	}
	
	/**
		Add integers, wrapping at 2^32.
	 */
	static inline function add( x : Int, y : Int ) : Int {
		var lsw = ( x & 0xFFFF) + ( y & 0xFFFF );
		var msw = ( x >> 16 ) + ( y >> 16) + ( lsw >> 16 );
		return ( msw << 16 ) | ( lsw & 0xFFFF );
	}

	/**
		Bitwise rotate a 32-bit number to the left
	 */
	static inline function rol( num : Int, cnt : Int ) : Int {
		return ( num << cnt ) | ( num >>> ( 32 - cnt ) );
	}

	/**
		Perform the appropriate triplet combination function for the current iteration
	*/
	static function ft( t : Int, b : Int, c : Int, d : Int ) : Int {
	  	if( t < 20 ) return ( b & c ) | ( ( ~b ) & d );
	  	if( t < 40 ) return b ^ c ^ d;
	  	if( t < 60 ) return ( b & c ) | ( b & d ) | ( c & d );
	  	return b ^ c ^ d;
	}

	/**
		Determine the appropriate additive constant for the current iteration
	*/
	static inline function kt( t : Int ) : Int {
	  return ( t < 20 ) ? 1518500249 : ( t < 40 ) ? 1859775393 : ( t < 60 ) ? -1894007588 : -899497514;
	}

	#end //!neko
	
}
