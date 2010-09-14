package jabber.util;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;

class SOCKS5 {
	
	public static function createOutgoingMessage( cmd : Int, digest : String ) : Bytes {
		var b = new BytesBuffer();
		b.addByte( 0x05 );
		b.addByte( cmd );
		b.addByte( 0x00 );
		b.addByte( 0x03 );
		b.addByte( digest.length );
		b.add( Bytes.ofString( digest ) );
		b.addByte( 0x00 );
		b.addByte( 0x00 );
		return b.getBytes();
	}
	
}
