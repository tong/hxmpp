package xmpp;


/**
	InfoQuery xmpp packet.
*/
class IQ extends Packet {
	
	public var type : IQType;
	public var ext : PacketElement;
	
	
	public function new( ?type : IQType, ?id : String, ?to : String, ?from ) {
		super( to, from, id );
		_type = xmpp.PacketType.iq;
		this.type = if( type != null ) type else xmpp.IQType.get;
	}
	
	
	public override function toXml(): Xml {
//		if( id == null ) throw "Invalid IQ packet, no id";
		if( type == null ) type = IQType.get;
		var x = super.addAttributes( Xml.createElement( "iq" ) );
		x.set( "type", Type.enumConstructor( type ) );
		x.set( "id", id );
		if( ext != null ) x.addChild( ext.toXml() );
		return x;
	}
	
	
	public static function parse( x : Xml ) : IQ {
		var iq = new IQ();
		iq.type = Type.createEnum( IQType, x.get( "type" ) );
	//	xmpp.Packet.parsePacketBase( iq, x );
		xmpp.Packet.parseAttributes( iq, x );
		for( c in x.elements() ) {
			switch( c.nodeName ) {
			case "error" : 
				iq.errors.push( xmpp.Error.parse( c ) );
			default :
				iq.properties.push( c );
			}
		}
		if( iq.properties.length > 0 )
			iq.ext = new PlainPacket( iq.properties[0] );
		return iq;
	}
	
	/**
		Creates a '<query xmlns="namspace"/>' xml tag.
	*/
    public static function createQueryXml( ns : String ) : Xml {
		var q = Xml.createElement( "query" );
		q.set( "xmlns", ns );
		return q;
	}
	
}
