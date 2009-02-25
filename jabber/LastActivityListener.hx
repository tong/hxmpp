package jabber;


/**
	<a href="http://xmpp.org/extensions/xep-0012.html">XEP-0012: Last Activity</a><br/>
*/
class LastActivityListener {
	
	/** Secs passed after last user activity */
	public var time : Int;
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		if( !stream.features.add( xmpp.LastActivity.XMLNS ) )
			throw "Last activity already added";
		this.stream = stream;
		time = 0;
		stream.addCollector( new jabber.core.PacketCollector( [ cast new xmpp.filter.IQFilter( xmpp.LastActivity.XMLNS, "query", xmpp.IQType.get ) ], handleRequest, true ) );
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		var r = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from );
		r.ext = new xmpp.LastActivity( time );
		stream.sendPacket( r );	
	}
	
}
