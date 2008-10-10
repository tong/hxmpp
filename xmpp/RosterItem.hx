package xmpp;

import xmpp.Roster;


class RosterItem {
	
	public var jid(default,null) : String;
	public var subscription : Subscription;
	public var name : String;
	public var askType : AskType;
	public var groups : List<String>;
	
	
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
		if( subscription != null ) xml.set( "subscription", getSubscriptionString( subscription ) );
		if( askType != null ) xml.set( "ask", getAskTypeString( askType ) );
		for( group in groups ) {
			var g = Xml.createElement( "group" );
			g.addChild( Xml.createPCData( group ) );
			xml.addChild( g );
		}
		return xml;
	}
	
	public function toString() : String {
		return toXml().toString();
	}
	
	
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
	
	public inline static function getSubscriptionString( s : Subscription ) : String {
		return switch( s ) {
			case Subscription.none 	 : "none";
			case Subscription.to 	 : "to";
			case Subscription.from 	 : "from";
			case Subscription.both 	 : "both";
			case Subscription.remove : "remove";
		}
	}
	
	public inline static function getSubscriptionType( s : String ) : Subscription {
		return switch( s ) {
			case "none" 	: Subscription.none;
			case "to" 		: Subscription.to;
			case "from" 	: Subscription.from;
			case "both" 	: Subscription.both;
			case "remove" 	: Subscription.remove;
			default : null;
		}
	}
	
	public inline static function getAskTypeString( t : AskType ) : String {
		return switch( t ) {
			case AskType.subscribe 	 : "subscribe";
			case AskType.unsubscribe : "unsubscribe";
		}
	}
	
	public inline static function getAskType( t : String ) : AskType {
		return switch( t ) {
			case "subscribe"   : AskType.subscribe;
			case "unsubscribe" : AskType.unsubscribe;
			default : null;
		}
	}
	
}
