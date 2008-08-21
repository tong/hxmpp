package xmpp;


class PacketCustomExtension {
	
	public var xml : Xml;
	
	public function new( ?xml : Xml ) {
		this.xml = xml;
	}
	
	public function toXml() : Xml {
		return xml;
	}
	
}
