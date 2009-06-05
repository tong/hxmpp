package jabber.file.io;

class IBOutput {
	
	//TODO
	public var __onComplete : Void->Void; 
	public var __onFail : Void->Void; 
	
	var stream : jabber.Stream;
	var reciever : String;
	var blockSize : Int;
	var sid : String;
	var seq : Int;
	var blocks : Array<String>;
	var iq : xmpp.IQ;
	
	public function new( stream : jabber.Stream, reciever : String, blockSize : Int, sid : String ) {
		this.stream = stream;
		this.reciever = reciever;
		this.blockSize = blockSize;
		this.sid = sid;
	}
	
	public function send( bytes : haxe.io.Bytes ) {
		seq = 0;
		blocks = new Array();
		// create blocks
		var t = new haxe.BaseCode( haxe.io.Bytes.ofString( util.Base64.CHARS ) ).encodeBytes( bytes ).toString();
		var pos = 0;
		while( true ) {
			var len = if( pos > t.length-blockSize ) t.length-pos else blockSize;
			var next = t.substr( pos, len );
			blocks.push( next );
			pos += len;
			if( pos == t.length )
				break;
		}
		iq = new xmpp.IQ( xmpp.IQType.set, null, reciever );
		sendNextPacket();
	}
	
	function sendNextPacket() {
		iq.id = stream.nextID()+"_ib"+seq;
		iq.properties = [xmpp.InBandByteStream.createDataElement( sid, seq, blocks[seq] )];
		stream.sendIQ( iq, handleChunkResponse );
	}
	
	function handleChunkResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			if( seq < blocks.length-1 ) {
				seq++;
				sendNextPacket();
			} else { // complete, .. close bytestream
				var iq = new xmpp.IQ( xmpp.IQType.set, null, reciever );
				iq.ext = new xmpp.InBandByteStream( xmpp.InBandByteStreamType.close, sid );
				var me = this;
				stream.sendIQ( iq, function(r:xmpp.IQ) {
					switch( r.type ) {
					case result :
						me.__onComplete();
					case error :
//TODO					me.__onError( new jabber.XMPPError( me.transfer, r ) );
					default : //#
					}
				} );
			}
		case error :
			//TODO 
		default :
			//TODO
		}
	}
	
}
