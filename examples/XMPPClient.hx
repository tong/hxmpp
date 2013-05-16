
import jabber.JID;
import jabber.JIDUtil;
import jabber.client.Stream;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.io.File;
import sys.FileSystem;
#end

private typedef ExampleAccount = {
	var jid : String;
	var password : String;
	var ip : String;
	var port : Int;
	var http : String;
}

/**
* Simple xmpp client base
*/
class XMPPClient {

	macro public static function getAccountFromFile( id : Int ) {
		var path = '../account_$id';
		if( !FileSystem.exists( path ) )
			throw 'account file not found [$path]';
		var p = File.getContent( path ).split(' ');
		var a : ExampleAccount = {
			jid : p[0],
			password : p[1],
			ip : p[2],
			port : ( p[3] != null ) ? Std.parseInt( p[3] ) : null,
			http : p[4]
		};
		return Context.makeExpr( a, Context.currentPos() );
	}

	public static var DEFAULT_ACCOUNT : ExampleAccount = {
		jid : 'romeo@om',
		password : 'test',
		ip : 'localhost',
		port : 5222,
		http : 'http://localhost/jabber',
	};

	var jid : String;
	var password : String;
	var ip : String;
	var port : Null<Int>;
	var http : String;

	var stream : Stream;

	function new( ?account : ExampleAccount ) {

		if( account == null )
			account = DEFAULT_ACCOUNT;

		jid = account.jid;
		password = account.password;
		ip = account.ip;
		port = account.port;
		http = account.http;

		if( ip == null ) ip = JIDUtil.domain( jid );
		if( port == null ) port = Stream.defaultPort;

		//TODO relax config even more (default passwor: 'test', ..)

		#if flash
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
	}

	function login() {

		trace( 'Connecting $jid ...' );
		
		#if js
		var cnx = if( http == null ) new jabber.SocketConnection( ip, port, false );
		else new jabber.BOSHConnection(  JIDUtil.domain( jid ), http );
		#else
		var cnx = new jabber.SocketConnection( ip, port, false );
		#end

		trace(http);
		trace(cnx);

		stream = new Stream( cnx );
		stream.onOpen = onStreamOpen;
		stream.onClose = onStreamClose;
		stream.open( new jabber.JID( jid ) );
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
		];
	}

	function getResource() : String {
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

	static inline function get_platform() : String {
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
