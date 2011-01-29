package xmpp.filter;

/**
	Filters jingle IQs.
*/
class JingleFilter extends IQFilter {
	
	/**  Jingle session-id */
	public var sid : String;
	/** Jingle transport namespace */
	public var transport : String;
	
	public function new( ?transport : String, ?sid : String, ?iqType : xmpp.IQType ) {
		super( xmpp.Jingle.XMLNS, iqType, "jingle" );
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
					if( e.get( "xmlns" ) != transport )
						return false;
				}
			}
		}
		return true;
	}
	
}
