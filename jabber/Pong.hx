package jabber;


/**
	Listens/Answers incoming pings.
	
	<a href="http://www.xmpp.org/extensions/xep-0199.html">XEP 199 - XMPP Ping</a>
*/
class Pong {
	
	public var stream(default,null) : Stream;
	
	
	public function new( stream : Stream ) {
		
		this.stream = stream;
		
		var c = new jabber.core.PacketCollector( [ cast new xmpp.filter.IQFilter( xmpp.Ping.XMLNS, null, xmpp.IQType.get ) ], handlePing, true );
		stream.addCollector( c );
		stream.features.push( xmpp.Ping.XMLNS );
	}


	function handlePing( iq : xmpp.IQ ) {
		if( stream.status == jabber.StreamStatus.open ) {
			var r = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from );
			r.ext = new xmpp.Ping();
			stream.sendData( r.toString() );
		}
	}
	
}
