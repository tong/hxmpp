package xmpp;




class IQMUCOwner extends IQ {
	
	public var items : List<MUCOwnerItem>;
	
	
	public function new() {
		super();
	}
	
	
	override public function toXml() : Xml {
		var xml = super.toXml();
		var query = IQ.createQuery( XMLNS );
		for( item in items ) {
			query.addChild( item.toXml() );
		}
		xml.addChild( query );
		return xml:
	}
}



class MUCOwnerItem {
}

class MUCOwnerDestroy {
}