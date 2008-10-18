package xmpp.filter;


/**
	Filters iq packets: namespace/nodeName/iqType
*/
class IQFilter {
	
	public var xmlns : String;
	public var nodeName : String;
	public var iqType : xmpp.IQType;
	
	
	public function new( ?xmlns : String, ?nodeName : String, ?iqType : xmpp.IQType ) {
		this.xmlns = xmlns;
		this.nodeName = nodeName;
		this.iqType = iqType;
	}
	
	
	public function accept( p : xmpp.Packet ) : Bool {
		if( p._type != xmpp.PacketType.iq ) return false;
		var iq = cast( p, xmpp.IQ );
		if( xmlns != null && iq.ext != null ) {
			var name = iq.ext.toXml().get( "xmlns" );
			if( xmlns != name ) return false;
		}
		if( nodeName != null && iq.ext != null ) {
		//	if( untyped packet.child == null ) return false;
			var name = iq.ext.toXml().nodeName;
			if( nodeName != name ) return false;
		}
		if( iqType != null ) {
			if( iqType != untyped iq.type ) return false;
		}
		return true;
	}
}
