package xmpp.sasl;

import haxe.crypto.Base64;
import haxe.crypto.Md5;
import haxe.io.Bytes;

/**
	[DIGEST-MD5 SASL Mechanism](ftp://ietf.org//rfc/rfc2831.txt)
*/
class MD5Mechanism implements Mechanism {

	public static inline var NAME = 'DIGEST-MD5';

	public var name(default,null) = NAME;

	public var serverType(default,null) : String;

	var username : String;
	var host : String;
	var password : String;
	var resource : String;

	public function new( serverType = "xmpp" ) {
		this.serverType = serverType;
	}

	public function createAuthenticationText( username : String, host : String, password : String ) : String {
		this.username = username;
		this.host = host;
		this.password = password;
		return null;
	}

	public function createChallengeResponse( challenge : String ) : String {
		var c = parseChallenge( challenge );
		return (c == null) ? "" : createResponse( host, serverType, username, c.realm, password, c.nonce );
	}

	public static function parseChallenge( challenge : String ) : { realm : String, nonce : String } {

		var c = Base64.decode( challenge ).toString();

		var s = c.split( "," );
		var map = new Map<String,String>();
		for( e in c.split( "," ) ) {
			var s = e.split( "=" );
			map.set( s[0], s[1] );
		}
	//	if( unquote( map.get( 'qop' ) ) != 'auth' )
	//		return null;
		if( map.exists( "rspauth" ) ) { // Negotiation complete
			return null;
		}

		return {
			realm : map.exists( "realm" ) ? unquote( map.get( "realm" ) ) : "",
			nonce : unquote( map.get( "nonce" ) ),
			//qop:
		};
	}

	public static function createResponse( host : String, serverType : String,  username : String, realm : String, password : String, nonce : String ) : String {

		var digest_uri = '$serverType/$host';
		var cnonce = createNonce( 10 );

		var X = '$username:$realm:$password';
		var Y = H( Bytes.ofString( X ) ); //.toString();
		var A1 = Y.toString()+':$nonce:$cnonce';
		var A2 = 'AUTHENTICATE:${digest_uri}';
		var HA1 = HH( A1 );
		var HA2 = HH( A2 );
		var KD = '$HA1:$nonce:00000001:$cnonce:auth:$HA2';
		var Z = HH( KD );

		var response = [
			'username="$username"',
			'cnonce="$cnonce"',
			'nonce="$nonce"',
			'realm="$realm"',
			'nc=00000001',
			'qop=auth',
			'digest-uri="$digest_uri"',
			'response=$Z',
			'charset=utf-8',
			//'authzid=',
		].join( ',' );

		return response;
	}

	static function createNonce( length : Int ) : String {
		var CHARS = Base64.CHARS.substr( 0, Base64.CHARS.length-2 );
		var buf = new Array<String>();
		for( i in 0...length )
			buf.push( CHARS.charAt( Std.int( Math.random() * CHARS.length-1 ) ) );
		return buf.join( '' );
	}

	static inline function H( bytes  : Bytes ) : Bytes {
		return Md5.make( bytes );
	}

	static inline function HH( str : String ) : String {
		return Md5.encode( str );
	}

	//static inline function quote( s : String ) : String return '"$s"';

	static inline function unquote( s : String ) : String
		return s.substr( 1, s.length - 2 );

}
