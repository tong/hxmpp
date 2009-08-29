package net.sasl;

/**
	<a href="ftp://ietf.org//rfc/rfc2831.txt">Using Digest Authentication as a SASL Mechanism</a>
	http://web.archive.org/web/20050224191820/http://cataclysm.cx/wip/digest-md5-crash.html
*/
class MD5Mechanism {
	
	public static var ID = "DIGEST-MD5";
	
	public var id(default,null) : String;
	public var serverType : String;
	
	var username : String;
	var host : String;
	var pass : String;
	
	public function new( serverType : String = "xmpp" ) {
		this.id = ID;
		this.serverType = serverType;
	}
	
	public function createAuthenticationText( username : String, host : String, pass : String ) : String {
		this.username = username;
		this.host = host;
		this.pass = pass;
		return null;
	}
	
	public function createChallengeResponse( challenge : String ) : String {
		var c = util.Base64.decode( challenge );
		var s = c.split( "," );
		var elements = new Hash<String>();
		for( e in s ) {
			var s = e.split( "=" );
			elements.set( s[0], s[1] );
		}
		if( Lambda.count( elements ) == 1 && elements.exists( "rspauth" ) ) {
			return ''; // negotiation complete
		}
		var realm = if( elements.exists( "realm" ) ) unquote( elements.get( "realm" ) ) else "";
		var nonce = unquote( elements.get( "nonce" ) );
		var digest_uri = serverType+"/"+host;
		//if( host != null ) digest_uri += "/"+host;
		var cnonce = hh( Date.now().toString() );
		// compute response
		var a1 = h( username+":"+realm+":"+pass )+":"+nonce+":"+cnonce;
		var a2 = "AUTHENTICATE:"+digest_uri;
		// create response string
		var b = new StringBuf();
		b.add( "username=" );
		b.add( quote( username ) );
		b.add( ",realm=" );
		b.add( quote( realm ) );
		b.add( ",nonce=" );
		b.add( quote( nonce ) );
		b.add( ",cnonce=" );
		b.add( quote( cnonce ) );
		b.add( ",nc=00000001,qop=auth,digest-uri=" );
		b.add( quote( digest_uri ) );
		b.add( ",response=" );
		b.add( hh( hh( a1 )+":"+nonce+":00000001:"+cnonce+":"+"auth"+":"+hh( a2 ) ) );
		b.add( ",charset=utf-8" );
		trace(b.toString());
		return b.toString();
	}
	
	inline function h( t : String)  {
		return crypt.MD5.encode( t, true );
	}
	
	inline function hh( t : String ) : String {
		return crypt.MD5.encode( t );
	}
	
	inline function quote( t : String ) : String {
		return '"'+t+'"';
	}
	
	inline function unquote( t : String ) : String {
		return t.substr( 1, t.length-2 );
	}
	
}
