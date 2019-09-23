package xmpp.sasl;

/*
	[The PLAIN Simple Authentication and Security Layer (SASL) Mechanism](http://www.ietf.org/rfc/rfc4616.txt)

	The PLAIN mechanism should not be used without adequate data security protection
	as this mechanism affords no integrity or confidentiality protections itself.
*/
class PlainMechanism implements Mechanism {

	public static inline var NAME = 'PLAIN';

	public var name(default,null) = NAME;
	//public var clientFirst(default,null) = true;

	public function new() {}

	public function createAuthenticationText( user : String, host : String, password : String ) : String {

		var z = String.fromCharCode( 0 );
		//TODO authzid
		return '$z$user$z$password';

		/*
		var b = new StringBuf();
		b.add( String.fromCharCode( 0 ) );
		b.add( user );
		b.add( String.fromCharCode( 0 ) );
		b.add( password );
		return b.toString();
		*/
	}

	public function createChallengeResponse( challenge : String ) : String {
		// This mechanism will never get a challenge from the server.
		return null;
	}

}
