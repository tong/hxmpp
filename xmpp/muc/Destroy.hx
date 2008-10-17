package xmpp.muc;


class Destroy {
	
	public var password : String;
	public var reason : String;
	public var jid : String;
	
	public function new( password : String, reason : String, jid : String ) {
		this.password = password;
		this.reason = reason;
		this.jid = jid;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "destroy" );
		if( jid != null ) x.set( "jid", jid );
		if( password != null ) x.addChild( util.XmlUtil.createElement( "password", password ) );
		if( reason != null ) x.addChild( util.XmlUtil.createElement( "reason", reason ) );
		return x;
	}
	
	//TODO public static function parse(x : Xml) {
	
}
