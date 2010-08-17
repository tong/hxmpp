package xmpp.filter;

// TODO remove
// .. own class just for the sid ?? .. no.not... use IQFilter and filter sids in jabber classes
// better.. replace by PacketElementFilter ?

/**
	Filters jingle packets.
*/
class JingleFilter extends IQFilter {
	
	/**  Jingle session id */
	public var sid : String;
	/** Jingle transport xml namespace */
	public var transport : String;
	
	public function new( ?transport : String, ?sid : String ) {
		super( xmpp.Jingle.XMLNS, "jingle" );
		this.transport = transport;
		this.sid = sid;
	}
	
	public override function accept( p : xmpp.Packet ) {
		if( !super.accept( p ) )
			return false;
		var iq : xmpp.IQ = untyped p;
		if( iq.x == null )
			return false;
		var x = iq.x.toXml();
		if( sid != null && x.get( "sid" ) != sid )
			return false;
		if( transport != null ) {
			for( e in x.elementsNamed( "content" ) ) {
				for( e in e.elementsNamed( "transport" ) ) {
					//haXe 2.06 fuckup
					#if flash
					if( e.get( "_xmlns_" ) != transport )
					#else
					if( e.get( "xmlns" ) != transport )
					#end
						return false;
				}
			}
		}
		return true;
	}
	
}
