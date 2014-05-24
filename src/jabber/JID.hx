/*
 * Copyright (c), disktree
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber;

/*
abstract JIDPart(String) {
	inline function new( s : String ) this = s;
	@:from public static inline function fromString( s : String ) : JIDPart {
		if( s.length > 1023 )
			throw 'max jid part size';
		return new JIDPart(s);
	}
}
*/

/**
	Unique jabber identifier.

	A JID is made up of a node (generally a username), a domain, and a resource.

		jid             = [ node "@" ] domain [ "/" resource ]
		domain          = fqdn / address-literal
		fqdn            = (sub-domain 1*("." sub-domain))
		sub-domain      = (internationalized domain label)
		address-literal = IPv4address / IPv6address

	Each allowable portion of a jid (node, domain, and resource) must not be more than 1023 bytes in length,
	resulting in a maximum total size (including the '@' and '/' separators) of 3071 bytes.
*/
class JID {
	
	/** Node (generally a username) part */
	public var node : String;
	
	/** Domain part */
	public var domain : String;
	
	/** Uniquely identifies a specific connection (e.g., a device or location) */
	public var resource : String;
	
	/** Jid without resource */
	public var bare(get,null) : String;
	
	public function new( ?s : String ) {
		if( s != null ) {
			if( !JIDUtil.isValid( s ) )
				throw 'invalid jid : $s'; 
			this.node = JIDUtil.node( s );
			this.domain = JIDUtil.domain( s );
			this.resource = JIDUtil.resource( s );
		}
	}
	
	function get_bare() : String {
		return (node == null || domain == null) ? null : '$node@$domain';
	}

	public function clone() : JID {
		var j = new JID();
		j.node = node;
		j.domain = domain;
		j.resource = resource;
		return j;
	}

	/*
	public inline function equals( jid : JID ) : Bool {
		return JIDUtil.compare( jid, this );
	}
	*/
	
	public function toString() : String {
		return (resource == null) ? get_bare() : '$node@$domain/$resource';
	}

	public static inline function isValid( jid : String ) : Bool {
		return JIDUtil.isValid( jid );
	}
	
}
