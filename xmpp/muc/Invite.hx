package xmpp.muc;

class Invite {
	
	public var to : String;
	public var reason : String;
	public var from : String;
	
	public function new( to : String, ?reason : String, ?from : String ) {
		this.to = to;
		this.reason = reason;
		this.from = from;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "invite" );
		if( to != null ) x.set( "to", to );
		if( reason != null ) x.set( "reason", reason );
		if( from != null ) x.set( "from", from );
		return x;
	}

	//TODO public static function parse( x : Xml ) :  {
	
}
