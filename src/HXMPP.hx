
#if macro
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
using StringTools;
using Lambda;
using haxe.io.Path;
#end

/**
	HXMPP - Jabber/XMPP library
*/
@:noDoc
class HXMPP {

	public static var VERSION = getHaxelibVersion();

	macro public static function getHaxelibVersion() : Expr {
		var v = Json.parse( File.getContent( 'haxelib.json' ) ).version;
		return Context.makeExpr( v, Context.currentPos() );
	}

	#if xmldoc

	static function importAll() {
		var root = Sys.getCwd();
		if( !root.endsWith( 'hxmpp/' ) ) {
			Sys.println( 'invalid path ($root)' );
			return;
		}
		Compiler.define( "doc_gen" );
		Sys.setCwd( 'src' );
		var modules = new Array<String>();
		searchModules( modules, 'jabber' );
		searchModules( modules, 'xmpp' );
		for( mod in modules ) {
			if( !mod.startsWith('jabber') && !mod.startsWith('xmpp') )
				continue;
			if( mod.startsWith('XSPF') )
				continue;
			if( mod == 'jabber.Scxml' )
				continue;
		}
		for( mod in modules )
			Context.getModule( mod );
		Sys.setCwd( root );
	}

	static function isDefined( flags : Array<String> ) : Bool {
		for( flag in flags )
			if( !Context.defined( flag ) )
				return false;
		return true;
	}

	//TODO holy mess!
	static function searchModules( modules : Array<String>, path : String ) {
		for( fileName in FileSystem.readDirectory( path ) ) {
			if( fileName.startsWith('_') || fileName.startsWith('.') || fileName.endsWith("2") )
				continue;
			switch fileName {
			//case 'haxe','microsoft': continue;
			case 'crypto','jingle','io','rtt','ssl': continue;
			case 'component': if( !Context.defined('jabber_component') ) continue;
			}
			var filePath = path.addTrailingSlash() + fileName;
			if( FileSystem.isDirectory( filePath ) ) {
				switch filePath {
				case 'jabber/data': continue;
				}
				searchModules( modules, filePath );
			} else {
				if( !filePath.endsWith('.hx') )
					continue;
				var className = filePath.substr( 0, filePath.length-3 ).replace('/','.');
				//trace( className );
				switch className {
				case 'jabber.BOSHConnection': if( !isDefined(['js','nodejs','cpp','neko']) ) continue;
				case 'jabber.SecureSocketConnection': continue;
				case 'jabber.jingle.RTMFPCall','jabber.jingle.RTMFPListener','jabber.jingle.RTMFPResponder': if( !Context.defined('flash') ) continue;
				case 'jabber.jingle.RTMPCall','jabber.jingle.RTMPListener','jabber.jingle.RTMPResponder': if( !Context.defined('flash') ) continue;
				case 'jabber.jingle.WebRTCSDPCall','jabber.jingle.WebRTCSDPListener','jabber.jingle.WebRTCSDPResponder': continue;
				case 'jabber.net.BOSHRequest': if( !isDefined(['cpp','neko']) ) continue;
				case 'jabber.util.Timer': continue;
				case 'jabber.util.FlashPolicy': continue;
				}
				//Context.getModule( className );
				modules.push( className );
			}
		}
	}

	#end // hxmpp_macro

}
