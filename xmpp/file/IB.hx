package xmpp.file;

class IB {
	
	public static var XMLNS = xmpp.NS.PROTOCOL+"/ibb";
	
	public var type : IBType;
	public var sid : String;
	public var blockSize : Null<Int>;
	public var seq : Int;
	public var data : String;
	
	public function new( type : IBType, sid : String, ?blockSize : Null<Int> ) {
		this.type = type;
		this.sid = sid;
		this.blockSize = blockSize;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( Type.enumConstructor( type ) );
		x.set( "xmlns", XMLNS );
		x.set( "sid", sid );
		switch( type ) {
		case open : x.set( "block-size", Std.string( blockSize ) );
		case data : x.set( "seq", Std.string( seq ) );
		default : //
		}
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	public static function parse( x : Xml ) : IB {
		var _type = Type.createEnum( IBType, x.nodeName );
		var ib = new IB( _type, x.get( "sid" ), Std.parseInt( x.get( "block-size" ) ) );
		if( _type == IBType.data ) {
			for( e in x.elements() ) {
				if( e.nodeName == "data" ) {
					ib.data = e.firstChild().nodeValue;
					break;
				}
			}
		}
		return ib;
	}
	
	public static function parseData( p : xmpp.Packet ) : { sid : String , seq : Int, data : String } {
		for( x in p.properties ) {
			if( x.nodeName == "data" ) {
				return { sid : x.get( "sid" ) , seq : Std.parseInt( x.get( "seq" ) ), data : x.firstChild().nodeValue };
			}
		}
		return null;
	}
	
	public static function createDataElement( sid : String, seq : Int, d : String ) : Xml {
		var x = util.XmlUtil.createElement( "data", d );
		x.set( "xmlns", XMLNS );
		x.set( "sid", sid );
		x.set( "seq", Std.string( seq ) );
		return x;
	}
	
}
