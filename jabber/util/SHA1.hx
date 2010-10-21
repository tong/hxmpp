package jabber.util;

#if (nodejs||php)

#if nodejs
import js.Node;
#end

class SHA1 {
	
	public static function encode( t : String ) : String {
		#if php
		return untyped __call__( "sha1", t );
		#else
		var h = Node.crypto().createHash( "sha1" );
		h.update( t );
		return h.digest( Node.HEX );
		#end
	}
	
}

#else
typedef SHA1 = haxe.SHA1;

#end
