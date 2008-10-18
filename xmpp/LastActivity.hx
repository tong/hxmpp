package xmpp;


class LastActivity {
	
	public static var XMLNS = "jabber:iq:last";
	
	public var seconds : Int;
	
	public function new( ?seconds : Int ) {
		this.seconds = seconds;
	}
	
	public function toXml() : Xml {
		var q = IQ.createQuery( XMLNS );
		q.set( "seconds", Std.string( seconds ) );
		return q;
	}
	
	public static function parse( x : Xml ) : LastActivity {
		var a = new LastActivity( Std.parseInt( x.get( "seconds" ) ) );
		return a;
	}
	
	public static inline function parseSeconds( x : Xml ) : Int {
		return Std.parseInt( x.get( "seconds" ) );
	}
	
}
