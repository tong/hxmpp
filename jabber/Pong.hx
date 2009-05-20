package jabber;

/**
	Listens for incoming ping messages and automaticly responds with a pong.
	<a href="http://www.xmpp.org/extensions/xep-0199.html">XEP 199 - XMPP Ping</a>
*/
class Pong {
	
	/**
		Informational callback that a ping has been recieved and responded to.
	*/
	public dynamic function onPong( entity : String ) : Void;

	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		if( !stream.features.add( xmpp.Ping.XMLNS ) )
			throw "Ping feature already added";
		this.stream = stream;
		stream.addCollector( new jabber.stream.PacketCollector( [ cast new xmpp.filter.IQFilter( xmpp.Ping.XMLNS, null, xmpp.IQType.get ) ], handlePing, true ) );
	}
	
	function handlePing( iq : xmpp.IQ ) {
		var r = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from );
		r.ext = new xmpp.Ping();
		stream.sendData( r.toString() );
		onPong( iq.from );
	}
		
}
