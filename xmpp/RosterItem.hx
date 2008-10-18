package xmpp;

import xmpp.Roster;
import xmpp.roster.AskType;
import xmpp.roster.Subscription;


/*
typedef TRosterItem = {
	var jid : String;
	var subscription : Subscription;
	var name : String;
	var askType : AskType;
	var groups : List<String>;
}*/


class RosterItem {
	
	//public var jid(default,null) : String;
	public var jid : String;
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
		if( jid == null ) throw "Invalid roster item";
		var xml = Xml.createElement( "item" );
		xml.set( "jid", jid );
		if( name != null ) xml.set( "name", name );
		if( subscription != null ) xml.set( "subscription", Type.enumConstructor( subscription ) );
		if( askType != null ) xml.set( "ask", Type.enumConstructor( askType ) );
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
	
	
	public static function parse( x : Xml ) : RosterItem {
		var item = new RosterItem( x.get( "jid" ) );
		item.subscription = Type.createEnum( Subscription, x.get( "subscription" ) );
		item.name = x.get( "name" );
		if( x.exists( "ask" ) ) item.askType = Type.createEnum( AskType, x.get( "ask" ) );
		for( group in x.elementsNamed( "group" ) ) {
			item.groups.add( group.nodeValue );
		}
		return item;
	}
	
	/*
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
	*/
	
}
