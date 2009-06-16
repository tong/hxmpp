package xmpp.roster;

class Item {
	
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
		this.groups = ( groups != null ) ? groups : new List();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "item" );
		x.set( "jid", jid );
		if( name != null ) x.set( "name", name );
		if( subscription != null ) x.set( "subscription", Type.enumConstructor( subscription ) );
		if( askType != null ) x.set( "ask", Type.enumConstructor( askType ) );
		for( group in groups )
			x.addChild( util.XmlUtil.createElement( "group", group ) );
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}

	public static function parse( x : Xml ) : xmpp.roster.Item {
		var i = new Item( x.get( "jid" ) );
		i.subscription = Type.createEnum( Subscription, x.get( "subscription" ) );
		i.name = x.get( "name" );
		if( x.exists( "ask" ) ) i.askType = Type.createEnum( AskType, x.get( "ask" ) );
		for( g in x.elementsNamed( "group" ) )
			i.groups.add( g.firstChild().nodeValue );
		return i;
	}
	
}
