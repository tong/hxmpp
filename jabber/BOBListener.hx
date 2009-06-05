package jabber;

/**
	Provides requesting entity with 'Bits Of Binary'.<br>
	<a href="http://xmpp.org/extensions/xep-0231.html">XEP-0231: Bits of Binary</a>
*/
class BOBListener {
	
	/** Request callback */
	public var onRequest : String->String->xmpp.BOB;
	
	public var stream(default,null) : jabber.Stream;

	public function new( stream : jabber.Stream, onRequest : String->String->xmpp.BOB ) {
		this.stream = stream;
		this.onRequest = onRequest;
		var f_iq : xmpp.PacketFilter = new xmpp.filter.IQFilter( xmpp.BOB.XMLNS, "data", xmpp.IQType.get );
		stream.addCollector( new jabber.stream.PacketCollector( [f_iq], handleRequest, true ) );
	}

	function handleRequest( iq : xmpp.IQ ) {
		var _bob = xmpp.BOB.parse( iq.x.toXml() );
		var _cid = xmpp.BOB.getCIDParts( _bob.cid );
		var bob : xmpp.BOB = onRequest( iq.from, _cid[1] );
		if( bob == null ) {
			//trace("NO BOB FOUND");
			//TODO check XEP for updates
			//.??
		} else {
			var r = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from );
			// encode here?
			bob.data =  new haxe.BaseCode( haxe.io.Bytes.ofString( util.Base64.CHARS ) ).encodeString( bob.data );
			r.x = bob;
			stream.sendPacket( r );
		}
	}
	
}
