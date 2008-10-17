package jabber;



/**
	Enable browser-based clients to make bidirectional cross-domain connections.
	
	<a href="http://xmpp.org/extensions/xep-0124.html">XEP-0124: Bidirectional-streams Over Synchronous HTTP</a>
	<a href="http://xmpp.org/extensions/xep-0206.html">XEP-0206: XMPP Over BOSH</a>
	
*/
class BOSHConnection extends jabber.core.StreamConnection {
	
	
	public function new( host : String, port : Int ) {
		super();
	}
	
	override function read( ?yes : Bool = true ) : Bool {
		trace("READ");
		return true;
	}
	
	override function connect() {
		trace("CONNECT");
		connected = true;
		onConnect();
	}
	
	public override function send( d : String ) : Bool {
		trace("SEND");
		var http = new haxe.Http( "127.0.0.1" );
		http.onData = function(d) {
			trace(d);
		};
		http.onError = function(e) {
			trace(e);
		};
		http.onStatus = function(s) {
			trace(s);
		};
		http.request( false );
		return true;
	}
	
}
