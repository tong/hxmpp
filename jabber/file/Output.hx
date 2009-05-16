package jabber.file;

/**
	Abstract base for file transfer data streams.
*/
class Output<T> {
	
	var transfer : T;

	function new( transfer : T ) {
		this.transfer = transfer;
	}
	
	public function start( bytes : haxe.io.Bytes ) {
		throw "Abstract method";
	}
	
}
