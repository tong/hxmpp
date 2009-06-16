package xmpp.filter;

/**
*/
class PacketFieldFilter {
	
	public var name : String;
	public var value : String;
	
	public function new( name : String, ?value : String ) {
		this.name = name;
		this.value = value;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		if( !Reflect.hasField( p, name ) ) return false;
		if( value == null ) return true;
		return Reflect.field( p, name ) == value;
	}
	
}
