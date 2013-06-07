
import jabber.JID;
import jabber.JIDUtil;
import jabber.client.Stream;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.io.File;
import sys.FileSystem;
#end

typedef AccountCredentials = {
	/*
	var user : String;
	var host : String;
	var password : String;
	var ip : String;
	var port : Int;
	var http : String;
	*/
	user : String,
	host : String,
	password : String,
	?ip : String,
	?port : Int,
	?http : String,
}

/**
	XMPP client base class for most of the examples
*/
class XMPPClient {

	macro public static function getAccountFromFile( id : String = "a" ) {
		var path = '../account_$id';
		if( !FileSystem.exists( path ) )
			throw 'account file not found : $path';
		var p = File.getContent( path ).split( ' ' );
		var a : AccountCredentials = {
			user : p[0],
			host : p[1],
			password : p[2],
			ip : p[3],
			port : ( p[4] != null ) ? Std.parseInt( p[4] ) : null,
			http : null
		};
		a.http = ( a.port == null ) ? p[4] : p[5];
		return Context.makeExpr( a, Context.currentPos() );
	}

	public static var defaultCredentials : AccountCredentials = {
		user : 'romeo',
		host : 'disktree.local',
		password : 'test',
		ip : 'localhost',
		port : jabber.client.Stream.PORT,
		http : 'localhost/http-bind'
	};

	var user : String;
	var host : String;
	var password : String;
	var ip : String;
	var port : Null<Int>;
	var http : String;

	var stream : Stream;

	function new( ?creds : AccountCredentials ) {

		if( creds == null )
			creds = defaultCredentials;

		user = creds.user;
		host = creds.host;
		password = creds.password;
		ip = creds.ip;
		port = creds.port;
		http = creds.http;

		if( ip == null ) ip = host;
		if( port == null ) port = Stream.defaultPort;

		#if flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
	}

	function login() {

		#if js
		var cnx = if( http == null ) new jabber.SocketConnection( ip, port, false );
		else new jabber.BOSHConnection( host, http );
		#else
		var cnx = new jabber.SocketConnection( ip, port, false );
		#end

		stream = new Stream( cnx );
		stream.onOpen = onStreamOpen;
		stream.onClose = onStreamClose;
		stream.open( new jabber.JID( user+'@'+host ) );
	}

	function logout() {
		if( stream != null )
			stream.close( true );
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

	function getSASLMechanisms() : Array<jabber.sasl.Mechanism> {
		return [
			new jabber.sasl.MD5Mechanism(),
			new jabber.sasl.PlainMechanism()
			//new jabber.sasl.LOGINMechanism()
		];
	}

	public function getResource() : String {
		return getPlatformResource();
	}

	public static function getPlatformResource() : String {
		return
			#if cpp 'hxmpp-cpp'
			#elseif cs 'hxmpp-cs'
			#elseif flash 'hxmpp-flash'
			#elseif java 'hxmpp-java'
			#elseif js 'hxmpp-js'
			#elseif neko 'hxmpp-neko'
			#elseif php 'hxmpp-php'
			#end;
	}

	public static inline function get_platform() : String {
		return #if cpp "cpp"
		#elseif cs "cs"
		#elseif flash "flash"
		#elseif java "java"
		#elseif js
			#if nodejs "nodejs" #elseif rhino "rhino" #else "js" #end
		#elseif neko "neko"
		#elseif php "php"
		#end;
	}

}
