/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package jabber.sasl;

/**
	<a href="http://xmpp.org/extensions/xep-0175.html">XEP-0175: Best Practices for Use of SASL ANONYMOUS</a><br/>
*/
class AnonymousMechanism {
	
	static function __init__() {
		NAME = "ANONYMOUS";
	}
	
	public static var NAME(default,null) : String;
	
	public var id(default,null) : String;
	
	/**
		Some servers may send a challenge to gather more information such as email address.<br/>
		Return any string value.
	*/
	public var challengeResponse : String;
	
	public function new( challengeResponse = "any" ) {
		this.id = NAME;
		this.challengeResponse = challengeResponse;
	}
	
	public function createAuthenticationText( user : String, host : String, pass : String, resource : String ) : String {
		return null; // Nothing to send in the <auth> body.
	}
	
	public function createChallengeResponse( c : String ) : String {
		return challengeResponse; // not required
	}
	
}
