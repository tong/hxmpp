package jabber.file;

/**
	Abstract base for outgoing file transfers (negotiations).
*/
class Transfer {
	
	public dynamic function onReject( t : Transfer ) : Void;
	public dynamic function onInit( t : Transfer ) : Void;
	public dynamic function onComplete( t : Transfer ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	public var reciever(default,null) : String;
	public var data(default,null) : haxe.io.Bytes;
	
	function new( stream : jabber.Stream, reciever : String ) {
		this.stream = stream;
		this.reciever = reciever;
	}
	
	public function init( data : haxe.io.Bytes ) {
		throw "Abstract method";
	}
	
}
