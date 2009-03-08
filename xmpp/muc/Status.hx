package xmpp.muc;


class Status {
	
	public static inline var MYSELF = 110;
	public static inline var ROOMNICK_CHANGED = 210;
	public static inline var WAITS_FOR_UNLOCK = 201;
	
	public var code : Int;
	
	public function new( code : Int ) {
		this.code = code;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "status" );
		x.set( "code", Std.string( code ) );
		return x;
	}
	
	public static function parse( x ) : Status {
		return new Status( Std.parseInt( x.get( "code" ) ) );
	}
	
}
