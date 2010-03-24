package jabber.sasl;

// TODO remove

/**
	SASL handshake.<br/>
	<a href="http://tools.ietf.org/html/rfc4422">RFC 4422</a><br>
*/
class Handshake {
	
	/** Registered mechanisms. */
	public var mechanisms : Array<TMechanism>;
	
	/** SASL mechanism used */
	public var mechanism : TMechanism;
	
	public function new() {
		mechanisms = new Array();
	}
	
	/*
	public function locateMechanism( id : String ) : TMechanism {
		for( m in mechanisms ) {
			if( id == id ) {
				return mechanism = m;
			}
		}
		return null;
	}
	*/
	
	/**
	*/
	public function getAuthenticationText( username : String, host : String, password : String ) : String {
		if( mechanism == null ) return null;
		return mechanism.createAuthenticationText( username, host, password );
	}
	
	/**
	*/
	public function getChallengeResponse( challenge : String ) : String {
		if( mechanism == null ) return null;
		return mechanism.createChallengeResponse( challenge );
	}
	
}
