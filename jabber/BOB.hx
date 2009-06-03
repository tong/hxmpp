package jabber;

/**
	Request entity for 'Bits Of Binary'.<br>
	<a href="http://xmpp.org/extensions/xep-0231.html">XEP-0231: Bits Of Binary.</a><br/>
*/
class BOB {
	
	public dynamic function onLoad( from : String, bob : xmpp.BOB ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	
	public function new( stream : jabber.Stream ) {
		this.stream = stream;
	}
	
	/**
		Load BOB from entity.
	*/
	public function load( from : String, cid : String ) {
		var iq = new xmpp.IQ( null, null, from );
		iq.ext = new xmpp.BOB( cid );
		stream.sendIQ( iq, handleResponse );
	}
	
	function handleResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onLoad( iq.from, xmpp.BOB.parse( iq.ext.toXml() ));
		case error : onError( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
	
}
