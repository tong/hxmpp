package xmpp;

/**
	InfoQuery XMPP packet.
*/
class IQ extends Packet {
	
	/** */
	public var type : IQType;
	/** */
	public var x : PacketElement;
	
	public function new( ?type : IQType, ?id : String, ?to : String, ?from ) {
		super( to, from, id );
		_type = xmpp.PacketType.iq;
		this.type = if( type != null ) type else xmpp.IQType.get;
	}
	
	public override function toXml(): Xml {
		//if( id == null ) throw "Invalid IQ packet, no id";
		if( type == null ) type = IQType.get;
		var xml = super.addAttributes( Xml.createElement( "iq" ) );
		xml.set( "type", Type.enumConstructor( type ) );
		xml.set( "id", id );
		if( x != null ) xml.addChild( x.toXml() );
		return xml;
	}
	
	public static function parse( x : Xml ) : IQ {
		var iq = new IQ();
		iq.type = Type.createEnum( IQType, x.get( "type" ) );
		Packet.parseAttributes( iq, x );
		for( c in x.elements() ) {
			switch( c.nodeName ) {
			case "error" :  iq.errors.push( xmpp.Error.parse( c ) );
			default : iq.properties.push( c );
			}
		}
		if( iq.properties.length > 0 )
			iq.x = new PlainPacket( iq.properties[0] );
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
	
	/**
	*/
	public static inline function createResult( iq : IQ ) : IQ {
		return new IQ( IQType.result, iq.id, iq.from );
	}
	
}
