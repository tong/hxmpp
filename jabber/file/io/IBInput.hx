package jabber.file.io;

import jabber.stream.PacketCollector;
import xmpp.filter.IQFilter;

class IBInput {
	
	//TODO
	//public var __onComplete : haxe.io.Bytes->Void;
	public var __onClose : Void->Void; 
	public var __onFail : String->Void; 
	
	public var data(getData,null) : haxe.io.Bytes;
	
	var stream : jabber.Stream;
	var initiator : String;
	var seq : Int;
	var buf : StringBuf;
	var cdata : PacketCollector;
	var sid : String;
	
	public function new( stream : jabber.Stream, initiator : String, sid : String ) {
		this.stream = stream;
		this.initiator = initiator;
		this.sid = sid;
		seq = 0;
		buf = new StringBuf();
		var ff : xmpp.PacketFilter = new xmpp.filter.PacketFromFilter( initiator );
		var cclose = new PacketCollector( [ ff, cast new IQFilter( xmpp.InBandByteStream.XMLNS, Type.enumConstructor( xmpp.InBandByteStreamType.close ), xmpp.IQType.set ) ], handleIBClose, false );
		stream.addCollector( cclose );
		cdata = new PacketCollector( [ ff, cast new IQFilter( xmpp.InBandByteStream.XMLNS, Type.enumConstructor( xmpp.InBandByteStreamType.data ), xmpp.IQType.set ) ], handleIBData, true );
		stream.addCollector( cdata );
	}
	
	function getData() : haxe.io.Bytes {
		return new haxe.BaseCode( haxe.io.Bytes.ofString( util.Base64.CHARS ) ).decodeBytes( haxe.io.Bytes.ofString( buf.toString() ) );
	}
	
	function handleIBData( iq : xmpp.IQ ) {
		var i = xmpp.InBandByteStream.parseData( iq ); //?
		if( seq != i.seq ) {
			__onFail( "In-band data packet loss ("+i.seq+")" );
			return;
		}
		if( i.sid != sid ) {
			__onFail( "Invalid SID" );
			return;
		}
		seq++;
		buf.add( i.data );
		stream.sendPacket( xmpp.IQ.createResult( iq ) );
		//onProgress( this );
	}
	
	function handleIBClose( iq : xmpp.IQ ) {
		// read success?
		stream.removeCollector( cdata );
		stream.sendPacket( xmpp.IQ.createResult( iq ) );
		__onClose();
	}
	
}
