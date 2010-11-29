package jabber.jingle.io;

class Transport {
	
	public var __onFail : String->Void;
	public var __onConnect : Void->Void;
	public var __onDisconnect : Void->Void;
	
	function new() {}
	
	public function connect() {
		throw new jabber.error.AbstractError();
	}
	
	public function close() {
		throw new jabber.error.AbstractError();
	}
	
	public function init() {
		throw new jabber.error.AbstractError();
	}
	
	public function toXml() : Xml {
		return throw new jabber.error.AbstractError();
	}
	
}
