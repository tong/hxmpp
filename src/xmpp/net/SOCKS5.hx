package xmpp.net;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;

//https://github.com/tong/hxmpp/blob/master/src/jabber/util/SOCKS5Input.hx

/**
	Internet protocol to exchange network packets between a client and server through a proxy server.

	https://tools.ietf.org/html/rfc1928
*/
@rfc(1928)
class SOCKS5 {

	/**

		+----+-----+-------+------+----------+----------+
		|VER | CMD |  RSV  | ATYP | DST.ADDR | DST.PORT |
		+----+-----+-------+------+----------+----------+
		| 1  |  1  | X'00' |  1   | Variable |    2     |
		+----+-----+-------+------+----------+----------+

	**/
	public static function createRequest(cmd: Int, digest: Bytes) : Bytes {
		var b = new BytesBuffer();
		b.addByte(0x05);
		b.addByte(cmd);
		b.addByte(0x00);
		b.addByte(0x03);
		b.addByte(digest.length);
		//b.add( Bytes.ofString( digest ) );
		b.add(digest);
		b.addByte(0x00);
		b.addByte(0x00);
		return b.getBytes();
	}

}
