package xmpp;


/**
	Plain/Custom XMPP packet.
*/
class PlainPacket extends Packet {
	
	/**
		Plain content of the packet.
	*/
	public var src : Xml;

	public function new( src : Xml ) {
		super();
		this.src = src;
	}
	
	override public function toXml(): Xml {
		return src;
	}
	
}
