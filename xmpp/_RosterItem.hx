package xmpp;

import xmpp.Roster;
import xmpp.roster.AskType;
import xmpp.roster.Subscription;


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
		if( jid == null ) throw new error.Exception( "Invalid roster item" );
		var x = Xml.createElement( "item" );
		x.set( "jid", jid );
		if( name != null ) x.set( "name", name );
		if( subscription != null ) x.set( "subscription", Type.enumConstructor( subscription ) );
		if( askType != null ) x.set( "ask", Type.enumConstructor( askType ) );
		for( group in groups ) {
			x.addChild( util.XmlUtil.createElement( "group", group ) );
		}
		return x;
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
			item.groups.add( group.firstChild().nodeValue );
		}
		return item;
	}
	
}
