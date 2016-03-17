package xmpp.sasl;

/*
	The PLAIN Simple Authentication and Security Layer (SASL) Mechanism: http://www.ietf.org/rfc/rfc4616.txt

	The PLAIN mechanism should not be used without adequate data security protection
	as this mechanism affords no integrity or confidentiality protections itself.
*/
@:keep
//class PlainMechanism extends Mechanism {
class PlainMechanism implements Mechanism {

	public static inline var NAME = 'PLAIN';

	public var id(default,null) = NAME;

	//public inline function new() super( NAME );
	public inline function new() {}

	public function createAuthenticationText( user : String, host : String, password : String, resource : String ) : String {
		var b = new StringBuf();
		b.add( String.fromCharCode( 0 ) );
		b.add( user );
		b.add( String.fromCharCode( 0 ) );
		b.add( password );
		return b.toString();
	}

	public inline function createChallengeResponse( c : String ) : String {
		return null; // This mechanism will never get a challenge from the server.
	}

}
