package xmpp;

import util.XmlUtil;


class SoftwareVersion {
	
	public static var XMLNS = "jabber:iq:version";
	
	public var name : String;
	public var version : String;
	public var os : String;
	
	public function new( ?name : String, ?version : String, ?os : String ) {
		this.name = name;
		this.version = version;
		this.os = os;
	}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS );
		if( name != null ) x.addChild( XmlUtil.createElement( "name", name ) );
		if( version != null ) x.addChild( XmlUtil.createElement( "version", version ) );
		if( os != null ) x.addChild( XmlUtil.createElement( "os", os ) );
		return x;
	}
	
	public inline function toString() : String { return toXml().toString(); }
	
	
	public static function parse( x : Xml ) : xmpp.SoftwareVersion {
		var f = new haxe.xml.Fast( x );
		return new xmpp.SoftwareVersion( f.node.name.innerData,
										 f.node.version.innerData,
										 ( f.hasNode.os ) ? f.node.os.innerData : null );
	}
	
}
