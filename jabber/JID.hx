package jabber;

import jabber.util.JIDUtil;


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
	
	public static inline var MAX_PART_SIZE = 1023;
	
	public var node(default,null) : String;
    public var domain(default,null) : String;
    public var resource(default,null) : String;
    /** JID without resource */
	public var bare(getBare,null) : String;
	
	var _full : String;
	var _bare : String;
	
	
	public function new( str : String ) {
		
		#if !JABBER_DEBUG // allows malformed jids for debugging
		if( !JIDUtil.isValid( str ) ) throw new error.Exception( "Invalid jid: "+str ); 
		#end
		
		this.node = JIDUtil.parseNode( str );
		this.domain = JIDUtil.parseDomain( str );
		this.resource = JIDUtil.parseResource( str );
 		
		_bare = node+"@"+domain;
		_full = ( resource == null ) ? _bare : _bare+"/"+resource;
	}
	
	
	function getBare() : String {
		return _bare;
	}
	
	
	public function toString() : String {
		return _full;
	}
	
}
