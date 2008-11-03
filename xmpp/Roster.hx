package xmpp;


/**
	Roster iq extension.
*/
class Roster extends List<xmpp.roster.Item> {
	
	public static var XMLNS = "jabber:iq:roster";
	
	
	public function new( ?items : Iterable<xmpp.roster.Item> ) {
		super();
		if( items != null ) for( i in items ) add( i );
	}
	
	
	public function toXml() : Xml {
		var q = IQ.createQueryXml( XMLNS );
		for( item in iterator() ) q.addChild( item.toXml() );
		return q;
	}
	
	public override function toString() : String {
		return toXml().toString();
	}
	
	
	public static function parse( x : Xml ) : xmpp.Roster {
		var r = new xmpp.Roster();
		for( item in x.elements() ) {
			if( item.nodeName == "item" ) r.add( xmpp.roster.Item.parse( item ) );
		}
		return r;
	}
	
}
