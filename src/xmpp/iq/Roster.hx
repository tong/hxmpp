package xmpp.iq;



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



class Roster extends List<RosterItem> {
	
	public static inline var XMLNS  = "jabber:iq:roster";

	
	public function toXml() : Xml {
		var query = xmpp.IQ.createQuery( XMLNS );
		for( item in iterator() ) query.addChild( item.toXml() );
		return query;
	}
	
	
	/**
	*/
	public static function parse( child : Xml ) : Roster {
		var r = new Roster();
		for( item in child.elements() ) {
			if( item.nodeName == "item" ) r.add( RosterItem.parse( item ) );
		}
		return r;
	}
	
}


/**
*/
class RosterItem {
	
	public var jid(default,null) 	: String;
	public var subscription 		: Subscription;
	public var name 				: String;
	public var askType 				: AskType;
	public var groups 				: List<String>;
	
	
	public function new( jid : String,
						 ?subscription : Subscription, ?name : String, ?askType : AskType, ?groups : List<String> ) {
		this.jid = jid;
		this.subscription = subscription;
		this.name = name;
		this.askType = askType;
		this.groups = if( groups != null ) groups else new List();
	}
	
	
	public function toXml() : Xml {
		var xml = Xml.createElement( "item" );
		if( jid != null ) xml.set( "jid", jid );
		if( name != null ) xml.set( "name", name );
		if( subscription != null ) xml.set( "subscription",  getSubscriptionString( subscription ) );
		if( askType != null ) xml.set( "ask",  getAskTypeString( askType ) );
		for( group in groups ) {
			var g = Xml.createElement( "group" );
			g.addChild( Xml.createPCData( group ) );
			xml.addChild( g );
		}
		return xml;
	}
	
//	public function toString() : String {
//		return toXml().toString();
//	}
	
	
	/**
	*/
	public static function parse( child : Xml ) : RosterItem {
		var item = new RosterItem( child.get( "jid" ) );
		item.subscription = getSubscriptionType( child.get( "subscription" ) );
		item.name = child.get( "name" );
		item.askType = getAskType( child.get( "ask" ) );
		//TODO
		for( group in child.elementsNamed( "group" ) ) {
			item.groups.add( group.nodeValue );
		}
		return item;
	}
	
	
	public static function getSubscriptionString( s : Subscription ) : String {
		return switch( s ) {
			case Subscription.none 		: "none";
			case Subscription.to 		: "to";
			case Subscription.from 		: "from";
			case Subscription.both 		: "both";
			case Subscription.remove 	: "remove";
		}
	}
	
	public static function getSubscriptionType( s : String ) : Subscription {
		return switch( s ) {
			case "none" 	: Subscription.none;
			case "to" 		: Subscription.to;
			case "from" 	: Subscription.from;
			case "both" 	: Subscription.both;
			case "remove" 	: Subscription.remove;
			default : null;
		}
	}
	
	public static function getAskType( t : String ) : AskType {
		return switch( t ) {
			case "subscribe" 	: AskType.subscribe;
			case "unsubscribe" 	: AskType.unsubscribe;
		}
	}
	
	public static function getAskTypeString( t : AskType ) : String {
		return switch( t ) {
			case AskType.subscribe 		: "subscribe";
			case AskType.unsubscribe 	: "unsubscribe";
		}
	}
}
