
import jabber.JID;
import jabber.client.Authentication;
import jabber.client.Stream;

using jabber.JIDUtil;

private typedef AccountCredentials = {
	jid : String,
	password : String,
	?ip : String,
	?port : Int,
	?http : String,
}

/**
	Basic jabber/xmpp client (boilerplate base)
*/
class XMPPClient {

	public static var defaultServer = 'jabber.disktree.net';
	public static var defaultAccountCredentials = {
		jid : 'romeo@$defaultServer',
		password : 'test',
		ip : 'localhost',
		port : Stream.defaultPort,
		http : '$defaultServer/http-bind'
	};

	public var jid(default,null) : String;
	public var password(default,null) : String;
	public var ip(default,null) : String;
	public var port(default,null) : Int = Stream.defaultPort;
	public var http(default,null) : String;
	
	public var use_http = false;

	var stream : Stream;

	public function new( jid : String, password : String, ?ip : String, ?http : String ) {
		
		this.jid = jid;
		this.password = password;
		this.ip = (ip == null || ip == "") ? jid.domain() : ip;
		this.http = http;
		
		#if (cs||java||php)
		use_http = false;
		#elseif flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
	}

	public function login() {
		var cnx = createStreamConnection();
		stream = new Stream( cnx );
		stream.onOpen = onStreamOpen;
		stream.onClose = onStreamClose;
		stream.open( jid );
	}

	public function logout() {
		if( stream != null )
			stream.close( true );
	}

	function onStreamOpen() {
		var mechs = createSASLMechanisms();
		var auth = new Authentication( stream, mechs );
		auth.onSuccess = onLogin;
		auth.onFail = onLoginFail;
		var resource = (stream.jid.resource == null) ? createResource() : stream.jid.resource;
		auth.start( password, resource );
	}

	function onStreamClose(?e) {
		if( stream != null )
			trace( (e!=null) ? e : 'XMPP stream closed' );
	}

	function onLogin() {
		trace( 'Authenticated as $jid' );
		new jabber.PresenceListener( stream, onPresence );
		new jabber.MessageListener( stream, onMessage );
	}

	function onLoginFail(e:String) {
		trace( 'Authentication failed : $e' );
	}

	function onPresence( p : xmpp.Presence ) {
	}

	function onMessage( m : xmpp.Message ) {
	}

	function createStreamConnection() : jabber.StreamConnection {
		var cnx : jabber.StreamConnection = null;
		#if (js||cpp||neko)
		if( use_http && http != null )
			cnx = new jabber.BOSHConnection( ip, http );
		#end
		if( cnx == null )
			cnx = new jabber.SocketConnection( ip );
		return cnx;
	}

	function createSASLMechanisms() : Array<jabber.sasl.Mechanism> {
		return [
			new jabber.sasl.MD5Mechanism(),
			//new jabber.sasl.PlainMechanism()
		];
	}

	function createResource() : String return 'hxmpp-'+platform();

	public static inline function platform() : String {
		return
			#if air "air"
			#elseif cpp "cpp"
			#elseif cra "cra"
			#elseif crx "crx"
			#elseif cs "cs"
			#elseif flash "flash"
			#elseif java "java"
			#elseif nodejs "nodejs"
			#elseif rhino "rhino"
			#elseif js "js"
			#elseif neko "neko"
			#elseif php "php"
			#else "unknown"
			#end;
	}

	/*
	public static function connect() : XMPPClient {
		var creds = readArguments();
		var client = new XMPP( creds.jid, creds.password, creds.ip, creds.http );
		client.login();
		return client;
	}
	*/

	#if !sys inline #end
	public static function readArguments() {
		#if sys
		var creds = defaultAccountCredentials;
		var argHandler = hxargs.Args.generate([
			@doc( 'Jabber id' ) ['-jid'] => function(jid:String) {
				creds.jid = jid;
			},
			@doc( 'Password' ) ['-password','-p'] => function(pass:String) {
				creds.password = pass;
			},
			@doc( 'Server ip address' ) ['-ip'] => function(ip:String) {
				creds.ip = ip;
			},
			@doc( 'Servers http address' ) ['-http'] => function(http:String) {
				creds.http = http;
			},
			_ => function(arg:String) throw "Unknown command: " +arg
		]);
		argHandler.parse( Sys.args() );
		return creds;
		#else
		return defaultAccountCredentials;
		#end
	}

}
