package xmpp;


enum Subscription {
	
	/** The user and subscriber have no interest in each other's presence.*/
	none;
	
	/** The user is interested in receiving presence updates from the subscriber. */
    to;
    
	/** The subscriber is interested in receiving presence updates from the user. */
	from;
	
	/** The user and subscriber have a mutual interest in each other's presence. */
	both;
	
	/** The user wishes to stop receiving presence updates from the subscriber. */
	remove;
}


enum AskType {
	
	/** Denotes that  a request to subscribe to a entities presence has been made. */
	subscribe;
	
	/** Denotes that a request to unscubscribe from a users presence has been made.*/
	unsubscribe;
}


/**
*/
class Roster extends List<xmpp.RosterItem> {
	
	public static var XMLNS = "jabber:iq:roster";
	
	
	public function new( ?items : Iterable<RosterItem> ) {
		super();
		if( items != null ) {
			for( item in items ) add( item );
		}
	}
	
	
	public function toXml() : Xml {
		var query = xmpp.IQ.createQuery( XMLNS );
		for( item in iterator() ) query.addChild( item.toXml() );
		return query;
	}
	
	public override function toString() : String {
		return toXml().toString();
	}
	
	
	public static function parse( child : Xml ) : xmpp.Roster {
		var r = new xmpp.Roster();
		for( item in child.elements() ) {
			if( item.nodeName == "item" ) {
				r.add( xmpp.RosterItem.parse( item ) );
			}
		}
		return r;
	}
	
}
