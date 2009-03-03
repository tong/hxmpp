package jabber;


class XMPPError {
	
	public var dispatcher(default,null) : Dynamic;
	public var from(default,null) : String;
	public var type(default,null) : xmpp.ErrorType;
	public var code(default,null) : Int;
	public var name(default,null) : String;
	public var text(default,null) : String;
	
	
	public function new( dispatcher : Dynamic, p : xmpp.Packet ) {
		var e = p.errors[0];
		if( e == null ) throw "Packet has no error";
		this.dispatcher = dispatcher;
		this.from = p.from;
		type = e.type;
		code = e.code;
		name = e.name;
		text = e.text;
	}
	
	#if JABBER_DEBUG
	public function toString() : String {
		return "XMPPError( "+from+", "+name+", "+code+", "+text+" )";
	}
	#end
	
}