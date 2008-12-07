package jabber.file;

import xmpp.IBB;


/**
TODO !! jabber.Stream

	Outgoing IBB bytestream.
	
	<a href="http://xmpp.org/extensions/xep-0047.html">XEP-0047: In-Band Bytestreams (IBB)</a>
	
	Useful for sending small payloads, such as files that would otherwise be too
	cumbersome to send as an instant message (such as a text file) or impossible
	to send (such as a small binary image file).
	
	Generally, IBB should be used as a last resort.
	
*/
class IBB {
	
	public static var defaultBlockSize = 1<<12;
	
	public dynamic function onComplete( ibs : IBB ) {}
	//public dynamic function onError() {}
	
	public var stream(default,null) : jabber.client.Stream;
	public var target(default,null) : String;
	public var blockSize(default,null) : Int;
	public var active(default,null) : Bool;
	public var seq(default,null) : Int;
//TODO	public var iqMode(default,null) : Bool;
	
	var bytes : haxe.io.Bytes;
	var bytesSent : Int; // pos
	var input : haxe.io.BytesInput;
	var sid : String;
	var baseCode : haxe.BaseCode;
	
	
	public function new( stream : jabber.client.Stream, target : String,
						 ?blockSize : Int, ?iqMode : Bool = false ) {
		
		this.stream = stream;
		this.target = target;
		this.blockSize = ( blockSize != null ) ? blockSize : defaultBlockSize;
	//	this.iqMode = iqMode;
		
		active = false;
		bytesSent = seq = 0;
		baseCode = new haxe.BaseCode( haxe.io.Bytes.ofString( util.Base64.CHARS ) );
	}
	
	
	public function init( bytes : haxe.io.Bytes ) {
		
		if( active ) throw "Inband stream already active";
		active = true;
		
		this.bytes = bytes;
		input = new haxe.io.BytesInput( bytes );
		sid = util.StringUtil.random64( 8 );
		
		var iq = new xmpp.IQ( xmpp.IQType.set, null, target, stream.jid.toString() );
		var ext = new xmpp.IBB( IBBType.open, sid, blockSize );
		iq.ext = ext;
		stream.sendIQ( iq, handleOpenResult );
	}
	
	
	function handleOpenResult( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result :
				// start sending chunks
				sendNextPacket();
				
			case error :
				//TODO
			
			default : //#
		}
	}
	
	function handleCloseResult( iq : xmpp.IQ ) {
	}
	
	function handleIQAcknowledge( iq : xmpp.IQ ) {
	}
	
	function handleStreamCloseResponse( iq : xmpp.IQ ) {
		trace("handleStreamCloseResponse");
	}
	
	function sendNextPacket() {
		var b = nextData();
		var output = baseCode.encodeBytes( b ).toString();
		var m = new xmpp.Message( null, target, null );
		m.properties.push( xmpp.IBB.createDataElement( sid, seq, output ) );
		m.id = "ibb_"+seq;
		if( stream.sendData( m.toString() ) ) {
			seq = if( ++seq == (1<<16) ) 0;
			bytesSent += b.length;
			if( bytesSent < bytes.length ) {
				sendNextPacket();
			} else {
				var iq = new xmpp.IQ( xmpp.IQType.set, null, target );
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
	
}
