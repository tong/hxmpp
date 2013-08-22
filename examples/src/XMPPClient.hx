
import jabber.JID;
import jabber.JIDUtil;
import jabber.client.Stream;
import haxe.Json;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

using StringTools;

typedef AccountCredentials = {
	user : String,
	host : String,
	password : String,
	?ip : String,
	?port : Int,
	?http : String,
}

/**
	Abstract base class for XMPP clients.
*/
class XMPPClient {

	public static var defaultAccountCredentials : AccountCredentials = {
		user : 'romeo',
		host : 'jabber.spektral.at',
		password : 'test',
		ip : null,
		port : Stream.PORT,
		http : 'jabber.spektral.at/http'
	};

	public var user(default,null) : String;
	public var host(default,null) : String;
	public var password(default,null) : String;
	public var ip(default,null) : String;
	public var port(default,null) : Null<Int>;
	public var http(default,null) : String;

	var stream : Stream;

	function new( ?creds : AccountCredentials ) {

		if( creds == null ) creds = defaultAccountCredentials;

		user = creds.user;
		host = creds.host;
		password = creds.password;
		ip = creds.ip;
		port = creds.port;
		http = creds.http;

		if( ip == null || ip == "" ) ip = host;
		if( port == null ) port = Stream.defaultPort;

		#if flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
	}

	public function login() {
		#if js
		var cnx = if( http == null )
				new jabber.SocketConnection( ip, port, false );
			else
				new jabber.BOSHConnection( host, http );
		#else
		var cnx = new jabber.SocketConnection( ip, port, false );
		#end
		stream = new Stream( cnx );
		stream.onOpen = onStreamOpen;
		stream.onClose = onStreamClose;
		stream.open( user+'@'+host );
	}

	public function logout() {
		if( stream != null )
			stream.close( true );
		else
			trace( 'no xmpp stream' );
	}

	function onStreamOpen() {
		var mechs = getSASLMechanisms();
		var auth = new jabber.client.Authentication( stream, mechs );
		auth.onSuccess = onLogin;
		auth.onFail = onLoginFail;
		var resource = stream.jid.resource == null ? getResource() : stream.jid.resource;
		auth.start( password, resource );
	}

	function onStreamClose( ?e ) {
		if( e == null )
			trace( 'xmpp stream closed : ${stream.jid}' );
		else
			trace( 'xmpp stream error : $e' );
	}

	function onLogin() {
		trace( 'Authenticated as : ${stream.jid}' );
	}

	function onLoginFail( ?e ) {
		trace( 'Authentication failed : $e' );
	}

	function getResource() : String {
		return getPlatformResource()+'_'+Date.now().getTime();
	}

	function getSASLMechanisms() : Array<jabber.sasl.Mechanism> {
		return [
			new jabber.sasl.MD5Mechanism(),
			new jabber.sasl.PlainMechanism()
		];
	}

	public static inline function getPlatformResource() : String {
		return 'hxmpp-'+get_platform();
	}

	public static inline function get_platform() : String {
		return
			#if air "air"
			#elseif cpp "cpp"
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

	macro public static function getAccountCredentials( path : String = "romeo.json" ) {
		if( !path.endsWith('.json') ) path += '.json';
		path = '../$path';
		if( !sys.FileSystem.exists( path ) )
			throw 'File not found : $path';
		var creds = haxe.Json.parse( sys.io.File.getContent( path ) );
		return Context.makeExpr( creds, Context.currentPos() );
	}

}
