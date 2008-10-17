package xmpp.muc;


class Item {
	
	public var actor : String;
	public var reason : String;
	public var continue_ : String;
	public var affiliation : Affiliation;
	public var jid : String;
	public var nick : String;
	public var role : Role;
	
	
	public function new() {}
	
	
	public function toXml() : Xml {
		var x = Xml.createElement( "item" );
		if( actor != null ) x.set( "actor", actor );
		if( reason != null ) x.set( "reason", reason );
		if( continue_ != null ) x.set( "continue", continue_ );
		if( affiliation != null ) x.set( "affiliation", Type.enumConstructor( affiliation ) );
		if( jid != null ) x.set( "jid", jid );
		if( nick != null ) x.set( "nick", nick );
		if( role != null ) x.set( "role", Type.enumConstructor( role ) );
		return x;
	}
	
	
	public static function parse( x : Xml ) : Item {
		//TODO
		var item = new Item();
		item.jid = x.get( "jid" );
		item.nick = x.get( "nick" );
		var _affiliation = x.get( "affiliation" );
		if( _affiliation != null ) item.affiliation = Type.createEnum( Affiliation, _affiliation );
		
		var _role = x.get( "role" );
		if( _role != null ) item.role = Type.createEnum( Role, _role );
		return item;
	}
	
}
