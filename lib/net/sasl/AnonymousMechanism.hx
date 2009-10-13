package net.sasl;

class AnonymousMechanism {
	
	static function __init__() {
		ID = "ANONYMOUS";
	}
	
	public static var ID(default,null) : String;
	
	public var id(default,null) : String;
	/**
		Some servers may send a challenge to gather more information such as email address.
		Return any string value.
	*/
	public var challengeResponse : String;
	
	public function new( challengeResponse = "anything" ) {
		id = ID;
		this.challengeResponse = challengeResponse;
	}
	
	public function createAuthenticationText( username : String, host : String, pw : String ) : String {
		return null; // Nothing to send in the <auth> body.
	}
	
	public function createChallengeResponse( chl : String ) : String {
		return challengeResponse; // not required
	}
	
}
