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
package jabber;

/**
	An XMPP address (JID).<br/>
	A JID is made up of a node (generally a username), a domain, and a resource.<br/>
	
	jid             = [ node "@" ] domain [ "/" resource ]<br/>
	domain          = fqdn / address-literal<br/>
	fqdn            = (sub-domain 1*("." sub-domain))<br/>
	sub-domain      = (internationalized domain label)<br/>
	address-literal = IPv4address / IPv6address<br/>
	
	Each allowable portion of a JID (node, domain, and resource) must not be more than 1023 bytes in length,<br>
	resulting in a maximum total size (including the '@' and '/' separators) of 3071 bytes.
*/
class JID {
	
	public var node : String;
    public var domain : String;
    public var resource : String;
    /** JID without resource */
	public var bare(getBare,null) : String;
	
	public function new( t : String ) {
		if( t != null ) {
			if( !JIDUtil.isValid( t ) )
				throw new jabber.error.Error( "Invalid JID ["+t+"]" ); 
			this.node = JIDUtil.parseNode( t );
			this.domain = JIDUtil.parseDomain( t );
			this.resource = JIDUtil.parseResource( t );
		}
	}
	
	function getBare() : String {
		return ( node == null || domain == null ) ? null : node+"@"+domain;
	}
	
	public function toString() : String {
		var j = getBare();
		return ( j == null ) ? null : ( resource == null ) ? j : j+="/"+resource;
	}
	
}
