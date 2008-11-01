package jabber.event;

import jabber.core.StreamBase;


/**
*/
class XMPPErrorEvent extends jabber.event.XMPPPacketEvent {
	
	public var type : xmpp.ErrorType;
	public var code : Int;
	public var name : String;
	public var text : String;
	
	public function new( s : StreamBase, p : xmpp.Packet ) {
		super( s, p );
		var e = p.errors[0];
		type = e.type;
		code = e.code;
		name = e.name;
		text = e.text;
	}
	
}
