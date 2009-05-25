package jabber;

/**
	<a href="http://www.xmpp.org/extensions/xep-0202.html">XEP 202 - EntityTime</a><br>
	Extension for comunicating the local time of an entity.
*/
class EntityTime {
	
	public dynamic function onLoad( e : String, t : xmpp.EntityTime ) {}
	public dynamic function onError( err : XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	/**
		Request the local time of another jabber entity.
	*/
	public function load( jid : String ) {
		var iq = new xmpp.IQ( null, null, jid );
		iq.ext = new xmpp.EntityTime();
		stream.sendIQ( iq, handleLoad );

	}
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onLoad( iq.from, xmpp.EntityTime.parse( iq.ext.toXml() ) );
		case error : onError( new XMPPError( this, iq ) );
		default : //#
		}
	}
	
}
