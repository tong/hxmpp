package xmpp.muc;


class Decline {
	
	public var reason : String;
	public var from : String;
	public var to : String;
	
	var nodeName : String;
	
	public function new() {
		nodeName = "decline";
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( nodeName );
		if( to != null ) x.set( "to", to );
		if( from != null ) x.set( "to", from );
		if( reason != null ) x.addChild( util.XmlUtil.createElement( "reason", reason ) );
		return x;
	}
	
}
