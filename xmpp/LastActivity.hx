package xmpp;

/**
	Discover when a disconnected user last accessed its server.
	
	<a href="http://xmpp.org/extensions/xep-0012.html">XEP-0012: Last Activity</a><br/>
*/
class LastActivity {
	
	public static var XMLNS = "jabber:iq:last";
	
	public var seconds : Int;
	
	public function new( ?seconds : Int ) {
		this.seconds = ( seconds != null ) ? seconds : -1;
	}
	
	public function toXml() : Xml {
		var q = IQ.createQueryXml( XMLNS );
		if( seconds > 0 ) q.set( "seconds", Std.string( seconds ) );
		return q;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	public static inline function parse( x : Xml ) : LastActivity {
		return new LastActivity( parseSeconds( x ) );
	}
	
	/**
		Parses/Returns just the time value of the given iq query xml.
	*/
	public static inline function parseSeconds( x : Xml ) : Int {
		return Std.parseInt( x.get( "seconds" ) );
	}
	
}
