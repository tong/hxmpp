package xmpp;

/**
*/
class InBandByteStream {
	
	public static var XMLNS = xmpp.NS.PROTOCOL+"/ibb";
	
	public var type : InBandByteStreamType;
	public var sid : String;
	public var blockSize : Null<Int>;
	public var data : String;
	
	public function new( type : InBandByteStreamType, sid : String, ?blockSize : Null<Int> ) {
		this.type = type;
		this.sid = sid;
		this.blockSize = blockSize;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( Type.enumConstructor( type ) );
		x.set( "xmlns", XMLNS );
		x.set( "sid", sid );
		if( blockSize != null ) x.set( "block-size", Std.string( blockSize ) );
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	public static function parse( x : Xml ) : InBandByteStream {
		var _type = Type.createEnum( xmpp.InBandByteStreamType, x.nodeName );
		var i = new xmpp.InBandByteStream( _type, x.get( "sid" ), Std.parseInt( x.get( "block-size" ) ) );
		if( _type == xmpp.InBandByteStreamType.data ) {
			for( e in x.elements() ) {
				if( e.nodeName == "data" ) {
					i.data = e.firstChild().nodeValue;
					break;
				}
			}
		}
		return i;
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
