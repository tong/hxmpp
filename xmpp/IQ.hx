package xmpp;


class IQ extends xmpp.Packet {
	
	public var type : IQType;
	public var ext : PacketElement;
	
	
	public function new( ?type : IQType, ?id : String, ?to : String, ?from ) {
		super( to, from, id );
		_type = xmpp.PacketType.iq;
		this.type = if( type != null ) type else xmpp.IQType.get;
	}

	
	public override function toXml(): Xml {
//		if( id == null ) throw "Invalid IQ packet, no id";
		if( type == null ) type = xmpp.IQType.get;
		var xml = super.addAttributes( Xml.createElement( "iq" ) );
		xml.set( "type", Type.enumConstructor( type ) );
		xml.set( "id", id );
		if( ext != null ) xml.addChild( ext.toXml() );
		return xml;
	}
	
	
	public static function parse( x : Xml ) : xmpp.IQ {
		var iq = new IQ();
		xmpp.Packet.parseAttributes( iq, x );
		iq.type = Type.createEnum( IQType, x.get( "type" ) );
		var ext = x.elements().next();
		if( ext != null ) {
			iq.ext = new PlainPacket( ext );
			// TODO test->
			for( el in x.elements() ) {
				switch( el.nodeName ) {
					case "error" : iq.errors.push( el );
					default : iq.properties.push( el );
				}
			}
		}
		return iq;
	}
	
	/**
		Creates '<query xmlns="namspace"/>' Xml object.
	*/
    public static inline function createQuery( ns : String ) : Xml {
		var q = Xml.createElement( "query" );
		q.set( "xmlns", ns );
		return q;
	}
	
}
