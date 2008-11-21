package jabber.event;


/**
*/
class XMPPErrorEvent<T:jabber.Stream> extends XMPPPacketEvent<T> {
	
	public var type(default,null) : xmpp.ErrorType;
	public var code(default,null) : Int;
	public var name(default,null) : String;
	public var text(default,null) : String;
	
	public function new( s : T, p : xmpp.Packet ) {
		super( s, p );
		var e = p.errors[0];
		type = e.type;
		code = e.code;
		name = e.name;
		text = e.text;
	}
	
}
