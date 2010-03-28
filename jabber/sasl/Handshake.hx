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
