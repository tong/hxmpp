package jabber.file;

/**
	Outgoing inband file transfer negotiator.
*/
class IBTransfer extends jabber.file.Transfer {
	
	public static var defaultBlockSize = 1 << 12; // 4096
	
	public var blockSize(default,null) : Int;
	public var sid(default,null) : String;
	
	public function new( stream : jabber.Stream, reciever : String, ?blockSize : Int ) {
		super( stream, reciever );
		this.blockSize = ( blockSize != null ) ? blockSize : defaultBlockSize;
	}
	
	public override function init( bytes : haxe.io.Bytes ) {
		this.data = bytes;
		// create random sid
		sid = util.StringUtil.random64( 8 );
		// send init request
		var iq = new xmpp.IQ( xmpp.IQType.set, null, reciever, stream.jid.toString() );
		iq.ext = new xmpp.InBandByteStream( xmpp.InBandByteStreamType.open, sid, blockSize );
		stream.sendIQ( iq, handleOpenResult );
	}
	
	function handleOpenResult( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			//var output = new IBFileOutput( this );
			//output.start( data );
			new IBOutput( this ).start( data );
		case error :
			var e = xmpp.Error.fromPacket( iq );
			if( e.name == xmpp.ErrorCondition.NOT_ACCEPTABLE ) {
				onReject( this );
				return;
			}
			onError( new jabber.XMPPError( this, iq ) );
			
		default : //#
		}
	}
	
}

