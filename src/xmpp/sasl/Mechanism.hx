package xmpp.sasl;

/**
	SASL mechanism.
*/
interface Mechanism {

	/***/
	var name(default,null) : String;

	/***/
	//var clientFirst(default,null) : Bool;

	/***/
	//function createAuthenticationText( user : String, host : String, password : String, resource : String ) : String;
	function createAuthenticationText( user : String, host : String, password : String ) : String;

	/***/
	function createChallengeResponse( challenge : String ) : String;

}
