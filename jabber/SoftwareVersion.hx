package jabber;

/**
	<a href="http://www.xmpp.org/extensions/xep-0092.html">XEP 0092 - Software Version</a>
*/
class SoftwareVersion {
	
	public dynamic function onLoad( jid : String, sv : xmpp.SoftwareVersion );
	public dynamic function onError( e : jabber.XMPPError );
	
	public var stream(default,null) : Stream;
	public var name : String;
	public var version : String;
	public var os : String;
	
	public function new( stream : Stream,
						 name : String, version : String, ?os : String ) {
		
		if( !stream.features.add( xmpp.SoftwareVersion.XMLNS ) )
			throw "SoftwareVersion feature already added";
		
		this.stream = stream;
		this.name = name;
		this.version = version;
		this.os = ( os != null ) ? os : util.SystemUtil.systemName();
		
		stream.addCollector( new jabber.stream.PacketCollector( [ cast new xmpp.filter.IQFilter( xmpp.SoftwareVersion.XMLNS, null, xmpp.IQType.get ) ], handleQuery, true ) );
	}
	
	/**
		Requests the software version of the given entity.
	*/
	public function load( jid : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.get, null, jid );
		iq.ext = new xmpp.SoftwareVersion();
		var me = this;
		stream.sendIQ( iq, function( r ) {
			switch( r.type ) {
			case result : me.onLoad( jid, xmpp.SoftwareVersion.parse( r.ext.toXml() ) );
			case error : me.onError( new jabber.XMPPError( me, r ) );
			default : //
			}
		} );
	}
	
	function handleQuery( iq : xmpp.IQ ) {
		var r = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from, stream.jid.toString() );
		r.ext = new xmpp.SoftwareVersion( name, version, os );
		stream.sendData( r.toString() );
	}
	
}
