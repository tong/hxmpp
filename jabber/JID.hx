package jabber;

import jabber.util.JIDUtil;

//TODO move to xmpp package

/**
	An XMPP address (JID).<br/>
	A JID is made up of a node (generally a username), a domain, and a resource.<br/>
	The node and resource are optional; domain is required.
	
	jid             = [ node "@" ] domain [ "/" resource ]<br/>
	domain          = fqdn / address-literal<br/>
	fqdn            = (sub-domain 1*("." sub-domain))<br/>
	sub-domain      = (internationalized domain label)<br/>
	address-literal = IPv4address / IPv6address<br/>
	
	Each allowable portion of a JID (node, domain, and resource) must not be more than 1023 bytes in length,<br>
	resulting in a maximum total size (including the '@' and '/' separators) of 3071 bytes.
*/
class JID {
	
	public static inline var MAX_PART_SIZE = 1023;
	
	public var node(default,null) : String;
    public var domain(default,null) : String;
    public var resource(default,null) : String;
	public var bare(getBare,null) : String;
	
	var cached 	: String;
	var cached_bare : String;
	
	
	public function new( str : String ) {
		
		#if !JABBER_DEBUG
		if( !JIDUtil.isValid( str ) ) throw new error.Exception( "Invalid jabber id: "+str ); 
		#end
		
		this.node = JIDUtil.parseNode( str );
		this.domain = JIDUtil.parseDomain( str );
		this.resource = JIDUtil.parseResource( str );
 
		toString(); // cache it.
	}
	
	
	function getBare() : String {
		if( cached_bare == null ) {
			var b = new StringBuf();
			b.add( node );
			b.add( "@" );
			b.add( domain );
			cached_bare = b.toString();
		}
		return cached_bare;
	}
	
	
	public function toString() : String {
		if( cached == null ) {
			var b = new StringBuf();
			b.add( node );
			b.add( "@" );
			b.add( domain );
			if( resource != null ) {
				b.add( "/" );
				b.add( resource );
			}
			cached = b.toString();
		}
		return cached;
	}
	
}
