package jabber;


/**
	<a href="http://www.xmpp.org/extensions/xep-0092.html">XEP 0092 - Software Version</a>
*/
class SoftwareVersion {
	
	public var onLoad : String->xmpp.SoftwareVersion->Void;
	public var onError : jabber.XMPPError->Void;
	
	public var stream(default,null) : Stream;
	public var name : String;
	public var version : String;
	public var os : String;
	
	
	public function new( stream : Stream,
						 name : String, version : String, ?os : String ) {
		
		this.stream = stream;
		this.name = name;
		this.version = version;
		this.os = ( os != null ) ? os : util.SystemUtil.systemName();
		
		stream.features.add( xmpp.SoftwareVersion.XMLNS );
		
		stream.addCollector( new jabber.core.PacketCollector( [ cast new xmpp.filter.IQFilter( xmpp.SoftwareVersion.XMLNS, null, xmpp.IQType.get ) ], handleQuery, true ) );
	}
	
	
	/**
		Requests the software version of the given entity.
	*/
	public function load( jid : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.get, null, jid );
		iq.ext = new xmpp.SoftwareVersion();
		var me = this;
		stream.sendIQ( iq, function( iq ) {
			switch( iq.type ) {
				case result :
					me.onLoad( jid, xmpp.SoftwareVersion.parse( iq.ext.toXml() ) );
				case error :
					me.onError( new jabber.XMPPError( me, iq ) );
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
