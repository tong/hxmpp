package xmpp;



/**
	Abstract/Basic XMPP packet.
*/
class Packet {
	
	public var to   		: String;
	public var from 		: String;
	public var id 			: String;	
	public var lang 		: String;
	
	public var _type(default,null) : PacketType;
	
	
	function new( ?to : String, ?from : String, ?id : String, ?lang : String ) {
		this.to = to;
		this.from = from;
		this.id = id ;
		this.lang = lang;
	}
	
	
	/**
		Creates the xml representaion of this packet.
	*/
	public function toXml() : Xml {
		return throw "Error, cannot create xml from abstract xmpp packet";
	}
	
	/**
		Creates the xml representaion of this packet as string.
	*/
	public function toString() : String {
		return toXml().toString();
	}
}
