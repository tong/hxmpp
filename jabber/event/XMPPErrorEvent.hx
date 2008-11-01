package jabber.event;


/**
*/
class XMPPErrorEvent<T:jabber.Stream> extends XMPPPacketEvent<T> {
	
	public var type : xmpp.ErrorType;
	public var code : Int;
	public var name : String;
	public var text : String;
	
	public function new( s : T, p : xmpp.Packet ) {
		super( s, p );
		var e = p.errors[0];
		type = e.type;
		code = e.code;
		name = e.name;
		text = e.text;
	}
	
}
