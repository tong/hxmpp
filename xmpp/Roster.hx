package xmpp;


/**
	Roster iq extension.
*/
class Roster extends List<xmpp.roster.Item> {
	
	public static var XMLNS = "jabber:iq:roster";
	
	public function new( ?items : Iterable<xmpp.roster.Item> ) {
		super();
		if( items != null ) {
			for( i in items ) add( i );
		}
	}
	
	public function toXml() : Xml {
		var q = IQ.createQueryXml( XMLNS );
		for( item in iterator() ) q.addChild( item.toXml() );
		return q;
	}
	
	#if JABBER_DEBUG public override function toString() : String { return toXml().toString(); } #end
	
	public static function parse( x : Xml ) : xmpp.Roster {
		var r = new xmpp.Roster();
		for( i in x.elements() ) {
			if( i.nodeName == "item" ) {
				r.add( xmpp.roster.Item.parse( i ) );
			}
		}
		return r;
	}
	
}
