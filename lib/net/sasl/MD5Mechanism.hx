package net.sasl;


/**
	
	<a href="ftp://ietf.org//rfc/rfc2831.txt">Using Digest Authentication as a SASL Mechanism</a>
	
	http://web.archive.org/web/20050224191820/http://cataclysm.cx/wip/digest-md5-crash.html
	
*/
class MD5Mechanism {
	
	public static var ID = "DIGEST-MD5";
	
	public var id(default,null) : String;
	
	public function new() {
		id = ID;
	}
	
	public function createAuthenticationText( username : String, host : String, password : String ) : String {
		return null;
	}
	
	//TODO
	public function createChallengeResponse( challenge : String ) : String {
		trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
		
		var username = "hxmpp"; 
		
		///////////////////////////////////
		
		var elements = parseChallenge( util.Base64.decode( challenge ) );
		trace(elements);
		if( !elements.exists( "qop" ) ) throw "Invalid md5 SASL, qop=auth doesnt exist";
		var nonce = elements.get( "nonce" );
		if( nonce == null ) throw "Invalid md5 SASL";
		var realm = if( elements.exists( "realm" ) ) elements.get( "realm" ) else "";
		var cnonce = util.StringUtil.random64( 32 );
		
		var digest_uri = "xmpp/disktree";
		
		var X = "hxmpp:disktree:test";
		var Y = haxe.Md5.encode( X );
		var A1 = Y+":"+nonce+":"+cnonce+":"+'hxmpp@disktree/norc';
		var A2 = 'AUTHENTICATE:'+digest_uri;
		var HA1 = haxe.Md5.encode( A1 );
		var HA2 = haxe.Md5.encode( A2 );
		var KD = HA1+":"+nonce+":00000001:"+cnonce+":auth:"+HA2;
		var response = haxe.Md5.encode( KD );
		
		var b = new StringBuf();
		b.add( 'username="' );
		b.add( username );
		b.add( '",realm=' );
		b.add( realm );
		b.add( ',nonce=' );
		b.add( nonce );
		b.add( ',cnonce="' );
		b.add( cnonce );
		b.add( '",nc=00000001,qop=auth,digest-uri="' );
		b.add( digest_uri );
		b.add( '",response=' );
		b.add( response );
		b.add( ',charset=utf-8' );//,authzid="' );
	//	b.add( 'hxmpp@disktree/norc"' );
		
		trace( b.toString() );
		return b.toString();
	}
	
	/*
	function hex_md5( num ){
		var str = "";
		var hex_chr = "0123456789abcdef";
		for( j in 0...4 ){
			str += hex_chr.charAt((num >> (j * 8 + 4)) & 0x0F) +
						 hex_chr.charAt((num >> (j * 8)) & 0x0F);
		}
		return str;
	}
	*/

	
	/**
		Parses a md5 challenge into a hash.
	*/
	public static function parseChallenge( ch : String ) : Hash<String> {
		var s = ch.split( "," );
		var h = new Hash<String>();
		for( e in s ) {
			var s = e.split( "=" );
			h.set( s[0], s[1] );
		}
		return h;
	}
	
}
