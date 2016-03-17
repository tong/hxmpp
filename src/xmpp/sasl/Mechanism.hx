package xmpp.sasl;

/**
	SASL mechanism type.
*/
interface Mechanism {

	var id(default,null) : String;

	function createAuthenticationText( user : String, host : String, password : String, resource : String ) : String;
	function createChallengeResponse( challenge : String ) : String;
}
