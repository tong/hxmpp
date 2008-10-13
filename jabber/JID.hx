package jabber;

import jabber.util.JIDUtil;


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
	public var barAdress(getBarAdress,null) : String;
	
	var cached 	: String;
	var cached_bar : String;
	
	
	public function new( str : String ) {
		
//TODO: local jid - domains !!
//		if( !JIDUtil.isValid( str ) ) throw "Invalid JID: " + str; temp for local testing -> domain(.net)
		
		this.node = JIDUtil.parseNode( str );
		this.domain = JIDUtil.parseDomain( str );
		this.resource = JIDUtil.parseResource( str );
 
		toString(); // cache it.
	}
	
	
	function getBarAdress() : String {
		if( cached_bar == null ) {
			var buf = new StringBuf();
			buf.add( node );
			buf.add( "@" );
			buf.add( domain );
			cached_bar = buf.toString();
		}
		return cached_bar;
	}
	
	
	public function toString() : String {
		if( cached == null ) {
			var j = new StringBuf();
			j.add( node );
			j.add( "@" );
			j.add( domain );
			if( resource != null ) {
				j.add( "/" );
				j.add( resource );
			}
			cached = j.toString();
		}
		return cached;
	}
	
}
