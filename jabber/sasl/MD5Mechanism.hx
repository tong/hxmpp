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
	<a href="ftp://ietf.org//rfc/rfc2831.txt">Using Digest Authentication as a SASL Mechanism</a>
	<a href="http://web.archive.org/web/20050224191820/http://cataclysm.cx/wip/digest-md5-crash.html">SASL and DIGEST-MD5 for XMPP</a>
*/
class MD5Mechanism {
	
	public static inline var NAME = 'DIGEST-MD5';
	
	public var id(default,null) : String;
	public var serverType : String;
	
	var username : String;
	var host : String;
	var pass : String;
	var resource : String;
	
	public function new( serverType : String = "xmpp" ) {
		this.id = NAME;
		this.serverType = serverType;
	}
	
	@:keep public function createAuthenticationText( username : String, host : String, pass : String, resource : String ) : String {
		this.username = username;
		this.host = host;
		this.pass = pass;
		this.resource = resource;
		return null;
	}
	
	public function createChallengeResponse( challenge : String ) : String {
		var c = MD5Calculator.parseChallenge( challenge );
		return MD5Calculator.run( host, serverType, username, c.realm, pass, c.nonce );
	}
	
}
