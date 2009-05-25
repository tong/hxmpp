package jabber.file;

import jabber.stream.PacketCollector;

/**
	Listens for incoming in band file transfer requests.
*/
class IBTransferListener extends TransferListener {
	
	public function new( stream : jabber.Stream, ?acceptMode : AcceptMode ) {
		
		super( xmpp.IBB.XMLNS, stream, acceptMode );
		
		// collect requests
		var f : xmpp.PacketFilter= new xmpp.filter.IQFilter( xmpp.InBandByteStream.XMLNS, "open", xmpp.IQType.set );
		stream.addCollector( new jabber.stream.PacketCollector( [f], handleOpenRequest, true ) );
	}
	
	function handleOpenRequest( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case set :
			var r = xmpp.InBandByteStream.parse( iq.ext.toXml() );
			//trace( r.blockSize );
			if( r.type == xmpp.InBandByteStreamType.open ) {
				switch( acceptMode ) {
				case manual :
					var inp = new IBInput( this );
					inp.handleRequest( iq );
					onRequest( inp );
				case acceptAll :
					var inp = new IBInput( this );
					onRequest( inp );
					inp.accept();
				case rejectAll :
					denyTransfer( iq );
				}
			}
		default : //#
		}
	}
	
}
