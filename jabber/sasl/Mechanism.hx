package jabber.sasl;

typedef Mechanism = {
	
	/**
	*/
	var id(default,null) : String;
	
	/**
	*/
	function createAuthenticationText( username : String, host : String, password : String ) : String;
	
	/**
	*/
	function createChallengeResponse( challenge : String ) : String;
	
}
