package xmpp.sasl;

/**
	[XEP-0175: Best Practices for Use of SASL ANONYMOUS](http://xmpp.org/extensions/xep-0175.html)
*/
class AnonymousMechanism implements Mechanism {

	public static inline var NAME = 'ANONYMOUS';

	public var name(default,null) = NAME;

	/**
		Some servers may send a challenge to gather more information such as email address.
	*/
	public var challengeResponse : String;

	public function new( challengeResponse = "any" ) {
		this.challengeResponse = challengeResponse;
	}

	public function createAuthenticationText( user : String, host : String, pass : String ) : String {
		return null; // Nothing to send in the <auth> body
	}

	public function createChallengeResponse( challenge : String ) : String {
		return challengeResponse; // Not required
	}

}
