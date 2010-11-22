package jabber.jingle.io;

class Transport {
	
	public var __onFail : Void->Void;
	public var __onConnect : Void->Void;
	public var __onDisconnect : Void->Void;
	
	function new() {}
	
	public function connect() {
		throw "Abstract method";
	}
	
	public function close() {
		throw "Abstract method";
	}
	
	public function init() {
		throw "Abstract method";
	}
	
	public function toXml() : Xml {
		return throw "Abstract method";
	}
	
}
