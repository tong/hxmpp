package xmpp.muc;


class Item {
	
	public var affiliation : Affiliation;
	public var role : Role;
	public var nick : String;
	public var jid : String;
	public var actor : String;
	public var reason : String;
	public var continue_ : String;
	
	public function new() {}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "item" );
		if( jid != null ) x.set( "jid", jid );
		if( nick != null ) x.set( "nick", nick );
		if( role != null ) x.set( "role", Type.enumConstructor( role ) );
		if( affiliation != null ) x.set( "affiliation", Type.enumConstructor( affiliation ) );
		if( actor != null ) {
			var e = Xml.createElement( "actor" );
			e.set( "jid", actor );
			x.addChild( e );
		}
		if( reason != null ) {
			x.addChild( util.XmlUtil.createElement( "reason", reason ) );
		}
		if( continue_ != null ) {
			var e = Xml.createElement( "continue" );
			e.set( "thread", continue_ );
			x.addChild( e );
		}
		return x;
	}
	
	
	public static function parse( x : Xml ) : Item {
		var p = new Item();
		if( x.exists( "affiliation" ) ) p.affiliation = Type.createEnum( Affiliation, x.get( "affiliation" ) );
		if( x.exists( "role" ) ) p.role = Type.createEnum( Role, x.get( "role" ) );
		if( x.exists( "nick" ) ) p.nick = x.get( "nick" );
		if( x.exists( "jid" ) ) p.jid = x.get( "jid" );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
				case "actor" : p.actor = e.get( "jid" );
				case "reason" : p.reason = e.firstChild().nodeValue;
				case "continue" : p.continue_ = e.get( "continue" );
			}
		}
		return p;
	}
	
}
