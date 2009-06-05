package jabber.file;

/**
	Incoming file transfer handler base.
*/
class FileReciever {
	
	public dynamic function onComplete( r : FileReciever ) : Void;
	public dynamic function onFail( r : FileReciever, m : String ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	public var xmlns(default,null) : String;
	public var initiator(default,null) : String;
	public var data(getData,null) : haxe.io.Bytes;
	
	var request : xmpp.IQ;
	
	function new( stream : jabber.Stream, xmlns : String ) {
		this.stream = stream;
		this.xmlns = xmlns;
	}
	
	function getData() : haxe.io.Bytes {
		return throw "Abstract error";
	}
	
	public function handleRequest( iq : xmpp.IQ ) : Bool {
		request = iq;
		initiator = iq.from;
		return true;
	}
	
	public function accept( yes : Bool = true ) {
		throw "Abstract method";
	}
	
}
