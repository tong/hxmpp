package jabber.file;

import jabber.file.io.IBInput;

/**
	Incoming in-band file transfer handler.
*/
class IBReciever extends FileReciever {
	
	public var blockSize(default,null) : Int;
	
	var input : IBInput;
	var sid : String;
	
	public function new( stream : jabber.Stream ) {
		super( stream, xmpp.file.IB.XMLNS );
	}
	
	override function getData() : haxe.io.Bytes {
		return input.data; //haxe.io.Bytes.ofString( input.data );
	}
	
	public override function handleRequest( iq : xmpp.IQ ) : Bool {
		//TODO
		var ib = xmpp.file.IB.parse( iq.x.toXml() );
		trace( ib.blockSize );
		sid = ib.sid;
		return super.handleRequest( iq );
	}
	
	public override function accept( yes : Bool = true ) {
		input = new IBInput( stream, initiator, sid );
		input.__onClose = handleInputClose;
		//input.__onComplete = handleIBClose;
		input.__onFail = handleInputFail;
		//input.__onProgress = handleIBProgress;
		stream.sendPacket( xmpp.IQ.createResult( request ) );
	}
	
	/*
	function handleInputProgress() {
		trace("HANDLE DATA");
	}
	*/
	
	function handleInputClose() {
		onComplete( this );
	}
	
	function handleInputFail( m : String ) {
		onFail( this, m );
	}
	
}
