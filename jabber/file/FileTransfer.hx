package jabber.file;

/**
	Outgoing file transfer base.
*/
class FileTransfer {
	
	//public dynamic function onReject( t : Transfer ) : Void;
	public dynamic function onInit( t : FileTransfer ) : Void;
	public dynamic function onComplete( t : FileTransfer ) : Void;
	public dynamic function onFail( t : FileTransfer ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	/** The namespace of the transfer method used */
	public var xmlns(default,null) : String;
	/** */
	public var sid(default,null) : String;
	/** JID of the transfer reciever */
	public var reciever(default,null) : String;
	/** Data to be transfered */
	public var data(default,null) : haxe.io.Bytes;
	 
	function new( stream : jabber.Stream, xmlns : String, reciever : String ) {
		this.stream = stream;
		this.xmlns = xmlns;
		this.reciever = reciever;
	}
	
	//TODO!! public function init( i : haxe.io.Input ) {
	public function init( data : haxe.io.Bytes ) {
		throw "Abstract method";
	}
	
}
