package net.sasl;

/**
	The PLAIN mechanism should not be used without adequate data security protection
	as this mechanism affords no integrity or confidentiality protections itself.
	
	<a href="http://www.ietf.org/rfc/rfc4616.txt">The PLAIN Simple Authentication and Security Layer (SASL) Mechanism</a>
*/
class PlainMechanism {
	
	static function __init__() {
		ID = "PLAIN";
	}
	
	public static var ID(default,null) : String;
	
	public var id(default,null) : String;
	
	public function new() { 
		id = ID;
	}
	
	public function createAuthenticationText( username : String, host : String, password : String ) : String {
		var b = new StringBuf();
		b.add( username );
		b.add( "@" );
		b.add( host );
		b.add( String.fromCharCode( 0 ) );
		b.add( username );
		b.add( String.fromCharCode( 0 ) );
		b.add( password );
		return b.toString();
	}
	
	public function createChallengeResponse( c : String ) : String {
		return null; // This mechanism will never get a challenge from the server.
	}
	
}
