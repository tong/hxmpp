package xmpp;


class MUCOwner {
	
	public static var XMLNS = xmpp.MUC.XMLNS+"#owner";
	
	public var items : List<xmpp.muc.Item>;
	public var destroy : xmpp.muc.Destroy;
	//public var empty : String;
	
	
	public function new() {
		items = new List();
	}
	
	
	public function toXml() : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		for( item in items ) {
			x.addChild( item.toXml() );
		}
		if( destroy != null ) x.addChild( destroy.toXml() );
		//empty
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
}
