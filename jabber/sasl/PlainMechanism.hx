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
	The PLAIN mechanism should not be used without adequate data security protection
	as this mechanism affords no integrity or confidentiality protections itself.
	
	<a href="http://www.ietf.org/rfc/rfc4616.txt">The PLAIN Simple Authentication and Security Layer (SASL) Mechanism</a>
*/
class PlainMechanism {
	
	public static var NAME = 'PLAIN';
	
	public var id(default,null) : String;
	
	public function new() { 
		id = NAME;
	}
	
	@:keep public function createAuthenticationText( username : String, host : String, password : String, resource : String ) : String {
		var b = new StringBuf();
		b.add( String.fromCharCode( 0 ) );
		b.add( username );
		b.add( String.fromCharCode( 0 ) );
		b.add( password );
		return b.toString();
	}
	
	public function createChallengeResponse( c : String ) : String {
		return null; // This mechanism will never get a challenge from the server.
	}
	
}
