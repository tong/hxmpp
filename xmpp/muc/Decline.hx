package xmpp.muc;


class Decline {
	
	public var reason : String;
	public var to : String;
	public var from : String;

	var nodeName : String;
	
	public function new( ?reason : String, ?to : String, ?from : String ) {
		nodeName = "decline";
		this.reason = reason;
		this.to = to;
		this.from = from;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( nodeName );
		if( to != null ) x.set( "to", to );
		if( from != null ) x.set( "to", from );
		if( reason != null ) x.addChild( util.XmlUtil.createElement( "reason", reason ) );
		return x;
	}
	
	//TODO public static function parse( x : Xml ) :  {
	
}
