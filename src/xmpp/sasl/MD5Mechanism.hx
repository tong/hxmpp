package xmpp.sasl;

/**
	DIGEST-MD5 SASL Mechanism (ftp://ietf.org//rfc/rfc2831.txt)
*/
class MD5Mechanism implements Mechanism {

	public static inline var NAME = 'DIGEST-MD5';

	public var id(default,null) = NAME;
	public var serverType(default,null) : String;

	var username : String;
	var host : String;
	var password : String;
	var resource : String;

	public function new( serverType = "xmpp" ) {
		this.serverType = serverType;
	}

	public function createAuthenticationText( username : String, host : String, password : String, resource : String ) : String {
		this.username = username;
		this.host = host;
		this.password = password;
		this.resource = resource;
		return null;
	}

	public function createChallengeResponse( challenge : String ) : String {
		var c = MD5Challenge.parse( challenge );
		return (c == null) ? "" : MD5Challenge.createResponse( host, serverType, username, c.realm, password, c.nonce );
	}

}
