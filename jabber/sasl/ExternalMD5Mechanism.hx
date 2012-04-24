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
	Calculates the MD5 hash on a web server instead of locally.
	This allows to create xmpp (web based) clients without including the (hardcoded) account password in the source code.
	
	Example of a remote calculator: https://gist.github.com/2464432
*/
class ExternalMD5Mechanism extends MD5Mechanism {
	
	public static inline var NAME = MD5Mechanism.NAME;
	
	/**
	 * The base URL of the challenge response calculator
	 */
	public var passwordStoreURL : String;
	
	public function new( passwordStoreURL : String, serverType : String = "xmpp" ) {
		super( serverType );
		this.passwordStoreURL = passwordStoreURL;
	}
	
	public override function createChallengeResponse( challenge : String ) : String {
		var c = MD5Calculator.parseChallenge( challenge );
		return haxe.Http.requestUrl( passwordStoreURL+"?host="+host+"&servertype="+serverType+"&username="+username+"&realm="+c.realm+"&nonce="+c.nonce );
	}
	
}
