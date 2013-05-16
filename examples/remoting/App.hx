
class ApiProxy extends haxe.remoting.AsyncProxy<Api> {}

class App extends XMPPClient {
	
	static var REMOTE_HOST = "julia@om/HXMPP";
	
	override function onLogin() {
		new jabber.PresenceListener( stream, onPresence );
		stream.sendPresence();
	}
	
	function onPresence( p : xmpp.Presence ) {
		if( p.from == REMOTE_HOST && p.type == null ) {

			var c = jabber.remoting.Connection.create( stream, REMOTE_HOST );
			c.setErrorHandler( function(e) trace( "HXR error : "+Std.string( e.name ) ) );
			
			// call functions manually ...
			c.inst.foo.call( [1,4], function(r:Int){ trace("Result: "+r); });
			
			// ... or create a remote proxy
			var api = new ApiProxy( c.inst );
			api.foo( 1, 3, function(r:Int){ trace("Result: "+r); });
		}
	}
	
	static function main() {
		new App().login();
	}
	
}
