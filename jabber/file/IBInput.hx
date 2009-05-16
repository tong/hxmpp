package jabber.file;

import jabber.stream.PacketCollector;

/**
	InBand file input.
*/
class IBInput extends Input {
	
	public var seq(default,null) : Int;
	public var blockSize(default,null) : Int;
	
	var c_close : PacketCollector;
	var c_data : PacketCollector;
	var buf : StringBuf;
	
	public function new( l : TransferListener ) {
		super( l );
		
	}
	
	override function getData() : haxe.io.Bytes {
		return haxe.io.Bytes.ofString( buf.toString() );
	}

	/**
	*/
	public override function accept( yes : Bool = true ) {
		if( yes ) {
			seq = 0;
			buf = new StringBuf();
			var ffrom : xmpp.PacketFilter = new xmpp.filter.PacketFromFilter( initiator );
			// collect IB close packets
			c_close = new PacketCollector( [ ffrom, cast new xmpp.filter.IQFilter( xmpp.InBandByteStream.XMLNS, Type.enumConstructor( xmpp.InBandByteStreamType.close ), xmpp.IQType.set ) ], handleStreamClose, false );
			listener.stream.addCollector( c_close );
			// collect IB data chunk packets
			c_data = new PacketCollector( [ ffrom, cast new  xmpp.filter.IQFilter( xmpp.InBandByteStream.XMLNS, Type.enumConstructor( xmpp.InBandByteStreamType.data ), xmpp.IQType.set ) ], handleDataPacket, true );
			listener.stream.addCollector( c_data );
			// send transfer accept result iq
			listener.stream.sendPacket( new xmpp.IQ( xmpp.IQType.result, requestIQ.id, initiator, listener.stream.jid.toString() ) );
		} else {
			listener.denyTransfer( requestIQ );
		}
	}
	
	function handleDataPacket( iq : xmpp.IQ ) {
		var i = xmpp.InBandByteStream.parseData( iq );
		if( seq != i.seq ) {
			onFail( "In band packet loss ("+i.seq+")", this );
			return;
		}
		seq++;
		buf.add( util.Base64.decode( i.data ) );
		listener.stream.sendPacket( new xmpp.IQ( xmpp.IQType.result, iq.id, initiator ) );
		onProgress( this );
	}
	
	function handleStreamClose( iq : xmpp.IQ ) {
		// remove data collector
		listener.stream.removeCollector( c_data );
		// send complete result iq
		listener.stream.sendPacket( new xmpp.IQ( xmpp.IQType.result, iq.id, initiator ) );
		// fire complete event
		onComplete( this );
	}
	
}
