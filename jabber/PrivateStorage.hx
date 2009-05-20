package jabber;

/**
	Extension to store any arbitrary XML on the server side.
	<a href="http://xmpp.org/extensions/xep-0049.html">XEP-0049: Private XML Storage</a><br/>
*/
class PrivateStorage {
	
	public dynamic function onStored( s : xmpp.PrivateStorage ) : Void;
	public dynamic function onLoad( s : xmpp.PrivateStorage ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : jabber.Stream;

	public function new( stream : jabber.client.Stream ) {
		this.stream = stream;
	}
	
	/**
		Store private data.
	*/
	public function store( name : String, namespace : String, data : Xml ) {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		var xt = new xmpp.PrivateStorage( name, namespace, data );
		iq.ext = xt;
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
			case result : me.onStored( xt );
			case error : me.onError( new jabber.XMPPError( me, iq ) );
			default://#
			}
		} );
	}
	
	/**
		Load private data.
	*/
	public function load( name : String, namespace : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.get );
		iq.ext = new xmpp.PrivateStorage( name, namespace );
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
			case result : me.onLoad( xmpp.PrivateStorage.parse( r.ext.toXml() ) );
			case error : me.onError( new jabber.XMPPError( me, iq ) );
			default://#
			}
		} );
	}
	
}
