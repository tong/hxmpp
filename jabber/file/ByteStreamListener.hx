package jabber.file;

class ByteStreamListener {
	
	public var handler : ByteStreamReciever->Void;
	
	public var stream(default,null) : jabber.Stream;
	
	public function new( stream : jabber.Stream, handler : ByteStreamReciever->Void ) {
		this.stream = stream;
		this.handler = handler;
		// collect file transfer requests
		var f : xmpp.PacketFilter = new xmpp.filter.IQFilter( xmpp.file.ByteStream.XMLNS, "query", xmpp.IQType.set );
		stream.addCollector( new jabber.stream.PacketCollector( [f], handleRequest, true ) );
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		//var bs = xmpp.file.ByteStream.parse( iq.ext.toXml() );
		var me = this;
		
		var r = new ByteStreamReciever( stream );
		
		#if php
		if( r.handleRequest( iq ) ) {
			handler( r );
		}
		#else
		util.Delay.run( function(){
		if( r.handleRequest( iq ) )
			me.handler( r );
		}, 1000 );
		#end
	}
	
}
