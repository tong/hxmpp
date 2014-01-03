
import haxe.ds.StringMap;
import jabber.JID;

class ApiProxy extends haxe.remoting.AsyncProxy<Api> {}

class App extends XMPPClient {
	
	var connections : StringMap<jabber.remoting.Connection>;

	override function onLogin() {
		
		super.onLogin();
		stream.sendPresence();

		var ctx = new haxe.remoting.Context();
		ctx.addObject( "inst", new Api() );
		new jabber.remoting.Host( stream, ctx );

		connections = new StringMap();
	}

	override function onPresence( p : xmpp.Presence ) {
		var jid = new JID( p.from );
		if( p.type == null && !connections.exists( jid.bare ) ) {
			
			var cnx = jabber.remoting.Connection.create( stream, jid.toString() );
			cnx.setErrorHandler( function(e) trace( "HXR error : "+Std.string(e) ) );
			connections.set( jid.bare, cnx );
			
			// Call functions manually
			cnx.inst.foo.call( [1,2], function(r:Int){ trace( "Result: "+r ); });

			// Or create a remote proxy
			var api = new ApiProxy( cnx.inst );
			api.foo( 2, 3, function(r:Int){ trace( "Result: "+r ); });
		}
	}
	
	static function main() {
		var creds = XMPPClient.readArguments();
		new App( creds.jid, creds.password, creds.ip, creds.http ).login();
	}
	
}
