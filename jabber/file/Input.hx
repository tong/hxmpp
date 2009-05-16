package jabber.file;

/**
	Abstract base for incoming file transfers.
*/
class Input {

	//public dynamic function onInit( t : FileTransfer ) : Void;
	public dynamic function onProgress( i : jabber.file.Input ) : Void;
	public dynamic function onComplete( i : jabber.file.Input ) : Void;
	public dynamic function onFail( m : String, i : jabber.file.Input ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var initiator(default,null) : String;
	public var data(getData,null) : haxe.io.Bytes;
	
	var listener : TransferListener;
	var requestIQ : xmpp.IQ;
	
	function new( l : TransferListener ) {
		this.listener = l;
	}
	
	function getData() : haxe.io.Bytes {
		return throw "Abstract getter";
	}
	
	public function handleRequest( iq : xmpp.IQ ) {
		this.requestIQ = iq;
		initiator = iq.from;
	}
	
	public function accept( yes : Bool = true ) {
		throw "Abstract method";
	}
	
	function denyTransfer() {
		var r = new xmpp.IQ( xmpp.IQType.error, requestIQ.id, initiator );
		r.errors.push(new xmpp.Error( xmpp.ErrorType.cancel, -1, xmpp.ErrorCondition.NOT_ACCEPTABLE ) );
		listener.stream.sendPacket( r );
	}
	
}
