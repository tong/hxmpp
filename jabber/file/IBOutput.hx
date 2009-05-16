package jabber.file;

/**
	Outgoing inband data stream.
*/
class IBOutput extends Output<IBTransfer> {
	
	var seq : Int;
	var blocks : Array<String>;
	var base64 : haxe.BaseCode;
	
	public function new( transfer : IBTransfer ) {
		super( transfer );
		base64 = new haxe.BaseCode( haxe.io.Bytes.ofString( util.Base64.CHARS ) );	
	}
	
	public override function start( bytes : haxe.io.Bytes ) {
		seq = 0;
		// create base64 blocks
		blocks = new Array();
		var pos = 0;
		while( true ) {
			var len = if( pos > bytes.length-transfer.blockSize ) bytes.length-pos else transfer.blockSize;
			var next = bytes.sub( pos, len );
			blocks.push( base64.encodeBytes( next ).toString() );
			pos += len;
			if( len != transfer.blockSize )
				break;
		}
		sendNextPacket();
	}
	
	function sendNextPacket() {
		var iq = new xmpp.IQ( xmpp.IQType.set, transfer.stream.nextID()+"_ib_"+seq, transfer.reciever );
		iq.properties.push( xmpp.InBandByteStream.createDataElement( transfer.sid, seq, blocks[seq] ) );
		transfer.stream.sendIQ( iq, handleChunkResponse );
	}
	
	function handleChunkResponse( iq : xmpp.IQ ) {
		var me = this;
		switch( iq.type ) {
		case result :
			if( seq < blocks.length-1 ) {
				seq++;
				sendNextPacket();
			} else {
				// close IB stream
				var iq = new xmpp.IQ( xmpp.IQType.set, null, transfer.reciever );
				iq.ext = new xmpp.InBandByteStream( xmpp.InBandByteStreamType.close, transfer.sid );
				me.transfer.stream.sendIQ( iq, function(r:xmpp.IQ) {
					switch( r.type ) {
					case result :
						me.transfer.onComplete( me.transfer );
					case error :
						me.transfer.onError( new jabber.XMPPError( me.transfer, r ) );
					default : //#
					}
				} );
			}
		case error :
			//TODO
			trace("IB FIELTRANSFER ERROR");
		default : //#
		}
	}
	
	//TODO function handleIBStreamClose
	
}

