package xmpp.sasl;

import haxe.ds.StringMap;
import haxe.crypto.Base64;
import haxe.crypto.Md5;
import haxe.io.Bytes;

/**
	Static methods for computing SASL-MD5 credentials.

	See:
	* ftp://ietf.org//rfc/rfc2831.txt
	* http://wiki.xmpp.org/web/SASLandDIGEST-MD5

*/
class MD5Challenge {

	/**
		Parses challenge and returns calculated realm and nonce
	*/
	public static function parse( challenge : String ) : { realm : String, nonce : String } {
		var c = Base64.decode( challenge ).toString();
		var s = c.split( "," );
		var map = new StringMap<String>();
		for( e in c.split( "," ) ) {
			var s = e.split( "=" );
			map.set( s[0], s[1] );
		}
	//	if( unquote( map.get( 'qop' ) ) != 'auth' )
	//		return null;
		if( map.exists( "rspauth" ) ) { // Negotiation complete
			return null;
			//return { realm : null, nonce : null }; //return null;
		}
		return {
			realm : map.exists( "realm" ) ? unquote( map.get( "realm" ) ) : "",
			nonce : unquote( map.get( "nonce" ) ),
			//qop:
		};
	}

	/**
		Calculate challenge response
	*/
	public static function createResponse( host : String, serverType : String,
										   username : String, realm : String,
										   pass : String, nonce : String ) : String {


		 //username="rob",realm="cataclysm.cx",nonce="OA6MG9tEQGm2hh",cnonce="OA6MHXh6VqTrRk",nc=00000001,qop=auth,digesturi="xmpp/cataclysm.cx",
		 //response=d388dad90d4bbd760a152321f2143af7,charset=utf-8,authzid="rob@cataclysm.cx/myResource"

		/*
		var digest_uri = '$serverType/$host';
		var cnonce = hh( Date.now().toString() );
		var a1 = h( '$username:$realm:$pass' )+':$nonce:$cnonce';
		var a2 = 'AUTHENTICATE:$digest_uri';

		var response = new Array<String>();
		response.push( 'username="$username"' );
		response.push( 'realm="$realm"' );
		response.push( 'nonce="$nonce"' );
		response.push( 'cnonce="$cnonce"' );
		response.push( 'nc=00000001' );
		response.push( 'qop=auth' );
		response.push( 'digest_uri="$digest_uri"' );
		response.push( 'response="'+hh( hh( a1 )+':$nonce:00000001:$cnonce:auth:'+hh( a2 ) )+'"' );
		response.push( 'charset=utf-8' );
		response.push( 'authzid="$username@$host/hxmpp"' );

		trace(response.join( ',' ));

		return response.join( ',' );
		*/


		/*
		var X = '$username:$realm:$pass';
		var Y = h(X);
		var A1 = '$Y:$nonce:$cnonce:$authzid';
		var A2 = 'AUTHENTICATE:$digest-uri';
		var HA1 = hh(A1);
		var HA2 = hh(A2);
		var KD = '$HA1:$nonce:nc:$cnonce:qop:$HA2';
		var Z = hh( KD );
		*/

		//return Z;
		//return null;

		/*
		var dict : StringMap = [
			'username' => quote( username ),
			'realm' => quote( realm ),
			'nonce' => quote( nonce ),
			'cnonce' => quote( cnonce ),
			'nc' => '00000001',
			'qop' => 'auth',
			'digesturi' => digest_uri,
			'response' => digest_uri,
		];
		*/


		var digest_uri = '$serverType/$host';
		var cnonce = hh( Date.now().toString() );
		var a1 = h( '$username:$realm:$pass' )+':$nonce:$cnonce';
		var a2 = 'AUTHENTICATE:$digest_uri';

		var b = new StringBuf();
		b.add( "username=" );
		b.add( quote( username ) );
		b.add( ",cnonce=" );
		b.add( quote( cnonce ) );
		b.add( ",nonce=" );
		b.add( quote( nonce ) );
		b.add( ",realm=" );
		b.add( quote( realm ) );
		b.add( ",nc=00000001,qop=auth,digest-uri=" );
		b.add( quote( digest_uri ) );
		b.add( ",response=" );
		b.add( hh( hh( a1 )+':$nonce:00000001:$cnonce:auth:'+hh( a2 ) ) );
		b.add( ",charset=utf-8" );
		//b.add( ",authzid=" );
		//b.add( quote(authzid) );
		return b.toString();

	}

	/*
	static function md5( s : String, encoding : String ) {
		var hash = crypto.createHash( 'md5' );
		hash.update( s );
		return hash.digest( encoding || 'binary' );
	}

	static inline function md5Hex( s : String ) return md5( s, 'hex' );
	*/
	//TODO all broken but the nodejs not
	static inline function h( s : String ) : String {
		#if nodejs
		var h = js.node.Crypto.createHash( "md5" );
		h.update( s );
		//return h.digest( raw ? NodeC.BINARY : NodeC.HEX );
		return h.digest( 'binary' );
		#else
		return Md5.make( Bytes.ofString(s) ).toString();

		#end
	}

	static inline function hh( s : String ) : String {
		return Md5.encode( s );
	}

	static inline function quote( s : String ) : String return '"$s"';
	static inline function unquote( s : String ) : String return s.substr( 1, s.length-2 );

}
