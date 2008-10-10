package xmpp.filter;

import xmpp.Packet;
import xmpp.PacketType;
import xmpp.IQ;
import xmpp.IQType;


/**
	Filters iq packets: namespace/nodeName/iqType
*/
class IQFilter {
	
	public var xmlns 	: String;
	public var nodeName : String;
	public var iqType 	: IQType;
	
	
	public function new( ?xmlns : String, ?nodeName : String, ?iqType : IQType ) {
		this.xmlns = xmlns;
		this.nodeName = nodeName;
		this.iqType = iqType;
	}
	
	
	public function accept( packet : xmpp.Packet ) : Bool {
		
		//TODO
		
		if( packet._type != PacketType.iq ) return false;
		
		if( xmlns != null ) {
			var name = packet.toXml().firstChild().get( "xmlns" );
			if( xmlns != name ) return false;
		}
		
		if( nodeName != null ) {
		//	if( untyped packet.child == null ) return false;
			var name = packet.toXml().firstChild().nodeName;
			if( nodeName != name ) return false;
		}
		
		if( iqType != null ) {
			if( iqType != untyped packet.type ) return false;
		}
		
		return true;
	}
}
