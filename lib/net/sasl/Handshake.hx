package net.sasl;


/**
	Abstract SASL handshake.<br/>
	<a href="http://tools.ietf.org/html/rfc4422">RFC 4422</a><br>

	SASL is conceptually a framework that provides an abstraction layer
	between protocols and mechanisms:
	
	  SMTP    LDAP    XMPP   Other protocols ...
	 	\       |    |      /
		 \      |    |     /
		SASL abstraction layer
		 /      |    |     \
		/       |    |      \
	EXTERNAL   GSSAPI  PLAIN   Other mechanisms ...
	
*/
class Handshake {
	
	/** Registered mechanisms. */
	public var mechanisms : Array<net.sasl.Mechanism>;
	
	/** Mechanism in use. */
	public var mechanism : net.sasl.Mechanism;
	
	
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
