package xmpp.sasl;

/**
	XEP-0175: Best Practices for Use of SASL ANONYMOUS
	
	http://xmpp.org/extensions/xep-0175.html
*/
class AnonymousMechanism implements Mechanism {

	public static inline var NAME = 'ANONYMOUS';

	public var id(default,null) : String;

	/**
		Some servers may send a challenge to gather more information such as email address.
	*/
	public var challengeResponse : String;

	public function new( challengeResponse = "any" ) {
		this.id = NAME;
		this.challengeResponse = challengeResponse;
	}

	@:keep
	public function createAuthenticationText( user : String, host : String, pass : String, resource : String ) : String {
		return null; // Nothing to send in the <auth> body
	}

	@:keep
	public function createChallengeResponse( c : String ) : String {
		return challengeResponse; // Not required
	}

}
