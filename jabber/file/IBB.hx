package jabber.file;

import xmpp.IBB;


/**

	Outgoing IBB.
	
	<a href="http://xmpp.org/extensions/xep-0047.html">XEP-0047: In-Band Bytestreams (IBB)</a>
	
	Useful for sending small payloads, such as files that would otherwise be too
	cumbersome to send as an instant message (such as a text file) or impossible
	to send (such as a small binary image file).
	
	Generally, IBB should be used as a last resort.
	
*/
class IBB {
	
	public static var defaultBlockSize = 1<<12;
	
	public dynamic function onComplete( s : IBB ) {}
	//public dynamic function onError() {}
	
	public var stream(default,null) : jabber.Stream;
	public var reciever(default,null) : String;
	public var blockSize(default,null) : Int;
	public var active(default,null) : Bool;
	public var seq(default,null) : Int;
//TODO	public var iqMode(default,null) : Bool;
	
	var bytes : haxe.io.Bytes;
	var bytesSent : Int; // pos
	var input : haxe.io.BytesInput;
	var sid : String;
	var baseCode : haxe.BaseCode;
	var blocks : Array<haxe.io.Bytes>;
	
	
	public function new( stream : jabber.Stream, reciever : String,
						 ?blockSize : Int, ?iqMode : Bool = false ) {
		
		this.stream = stream;
		this.reciever = reciever;
		this.blockSize = ( blockSize != null ) ? blockSize : defaultBlockSize;
	//	this.iqMode = iqMode;
		
		active = false;
		bytesSent = 0;
		seq = 0;
		baseCode = new haxe.BaseCode( haxe.io.Bytes.ofString( util.Base64.CHARS ) );
	}
	
	
	//public function init( i : haxe.io.BytesInput ) {
	public function init( bytes : haxe.io.Bytes ) {
			
		if( active ) throw "Inband stream already active";
		active = true;
		
		trace(bytes.length);
		
		this.bytes = bytes;
		input = new haxe.io.BytesInput( bytes );
		sid = util.StringUtil.random64( 8 );
		
		// TODO create blocks, encode blocks base64
		blocks = new Array();
		var pos = 0;
		var added = 0;
		
		while( true ) {
			var len = if( added > bytes.length-blockSize ) bytes.length-added else blockSize;
			var next = bytes.sub( pos, len );
			added += next.length;
			var enc = baseCode.encodeBytes( next );
			blocks.push( enc );
			if( len < blockSize ) break;
		}
		//trace(blocks.join("").length);
		trace("#############################");
	//	var left = bytes.length-bytesSent;
	//	var len = ( left < blockSize ) ? left : blockSize;
	//	return bytes.sub( bytesSent, len );
		
		var iq = new xmpp.IQ( xmpp.IQType.set, null, reciever );
		var ext = new xmpp.IBB( IBBType.open, sid, blockSize );
		iq.ext = ext;
		stream.sendIQ( iq, handleOpenResult );
	}
	
	function sendNextPacket() {
		var output = blocks[seq].toString();
		var m = new xmpp.Message( null, reciever, null );
		m.properties.push( xmpp.IBB.createDataElement( sid, seq, output.toString() ) );
		m.id = "ibb_"+seq;
		if( stream.sendData( m.toString() ) ) {
			if( seq < blocks.length-1 ) {
				trace("sending next packet..");
				seq++;
				sendNextPacket();
			} else {
				trace("transfer complete");
				var iq = new xmpp.IQ( xmpp.IQType.set, null, reciever );
				iq.ext = new xmpp.IBB( IBBType.close, sid );
				stream.sendIQ( iq, handleStreamCloseResponse );
			}
		}
	}
	
	/*
	function sendNextPacket() {
		var b = nextData();
		var output = baseCode.encodeBytes( b ).toString();
		var m = new xmpp.Message( null, reciever, null );
		m.properties.push( xmpp.IBB.createDataElement( sid, seq, output.toString() ) );
		m.id = "ibb_"+seq;
		if( stream.sendData( m.toString() ) ) {
			bytesSent += b.length;
			if( bytesSent < bytes.length ) {
				if( ++seq == (1<<16) ) seq = 0;
				sendNextPacket();
			} else {
				var iq = new xmpp.IQ( xmpp.IQType.set, null, reciever );
				iq.ext = new xmpp.IBB( IBBType.close, sid );
				stream.sendIQ( iq, handleStreamCloseResponse );
			}
		}		
	}
	
	function nextData() : haxe.io.Bytes {
		var left = bytes.length-bytesSent;
		var len = ( left < blockSize ) ? left : blockSize;
		return bytes.sub( bytesSent, len );
	}
	*/
	
	function handleOpenResult( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result : // start sending data chunks
				sendNextPacket();
			case error :
				//TODO
			default : //#
		}
	}
	
	function handleCloseResult( iq : xmpp.IQ ) {
		//TODO
	}
	
	function handleIQAcknowledge( iq : xmpp.IQ ) {
		//TODO
	}
	
	function handleStreamCloseResponse( iq : xmpp.IQ ) {
		trace("handleStreamCloseResponse");
	}
	
}
