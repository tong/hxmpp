package xmpp;


class Caps {
	
	public static var XMLNS = "http://jabber.org/protocol/caps";
	
	/**
		The hashing algorithm used to generate the verification string
	*/
	public var hash : String; // fe SHA-1
	/**
		A URI that uniquely identifies a software application, typically
		a URL at the website of the project or company that produces the software
	*/
	public var node : String;
	/**
		A string that is used to verify the identity and supported features of the entity
	*/
	public var ver : String;
	
	public function new( hash : String, node : String, ver : String) {
		this.hash = hash;
		this.node = node;
		this.ver = ver;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "c" );
		x.set( "xmlns", XMLNS );
		x.set( "hash", hash );
		x.set( "node", node );
		x.set( "ver", ver );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.Caps {
		return new Caps( x.get( "hash" ), x.get( "node" ), x.get( "ver" ) );
	}
	
}
