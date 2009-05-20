package jabber;

/**
	Listens/Answers time requests.
	<a href="http://www.xmpp.org/extensions/xep-0202.html">XEP 202 - EntityTime</a>
*/
class EntityTimeListener {
	
	public var stream(default,null) : Stream;
	public var time(default,null) : xmpp.EntityTime;
	 
	public function new( stream : Stream, ?tzo : String = "00:00" ) {
		if( !stream.features.add( xmpp.EntityTime.XMLNS ) )
			throw "EntityTime listener already added";
		this.stream = stream;
		time = new xmpp.EntityTime( tzo );
		stream.addCollector( new jabber.stream.PacketCollector( [ cast new xmpp.filter.IQFilter(xmpp.EntityTime.XMLNS,"time",xmpp.IQType.get)], handleRequest, true ) );
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		var r = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from );
		time.utc = xmpp.DateTime.current();
		r.ext = time;
		stream.sendPacket( r );	
	}
	
}
