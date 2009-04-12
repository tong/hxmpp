package jabber.client;

/**
	Abstract client account authentication.
*/
class Authentication {
	
	public dynamic function onSuccess() : Void;
	public dynamic function onFail( ?e : jabber.XMPPError ) : Void;
	
	public var resource(default,null) : String;
	public var stream(default,null) : Stream;
	
	function new( stream : Stream ) {
		this.stream = stream;
	}
	
	public function authenticate( password : String, ?resource : String ) : Bool {
		return throw new error.AbstractError();
	}
	
}
