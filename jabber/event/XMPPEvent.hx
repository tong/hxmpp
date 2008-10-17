package jabber.event;

import jabber.core.StreamBase;


/**
	For debugging only.
*/
class XMPPEvent {
	
	public var stream(default,null) : StreamBase;
	public var data(default,null) : String;
	public var incoming(default,null) : Bool;
	
	
	public function new( stream : StreamBase, data : String, incoming : Bool ) {
		this.stream = stream;
		this.data = data;
		this.incoming = incoming;
	}
	
	
	public function toString() : String {
		return "xmpp("+stream+","+data+","+incoming+")";
	}
	
}
