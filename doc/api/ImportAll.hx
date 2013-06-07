
import sys.FileSystem;
import sys.io.File;
import haxe.macro.Compiler;
import haxe.macro.Context;

using Lambda;
using StringTools;

class ImportAll {

	static var EXCLUDE = ['jabber/component','jabber/io','jabber/jingle','jabber/jingle2', 'jabber/data', 'jabber/SecureSocketConnection.hx'];

	static function addPackage( path : String ) {
		for( f in FileSystem.readDirectory( path ) ) {
			if( f.startsWith('_') )
				continue;
			var p = '$path/$f';
			if( EXCLUDE.has( p ) )
				continue;
			if( FileSystem.isDirectory( p ) )
				addPackage( p );
			else {
				var cl = p.substr( 0, p.length-3 ).replace('/','.');
				Context.getModule(cl);
			}
		}
	}

	static function main() {
		trace("YOYOY");
	}

	public static function run( ?pack ) {
		if( pack == null ) {
			pack = "";
			Compiler.define( "doc_gen" );
		}
		switch( pack ) {
		case "php":
			if( !Context.defined("php") ) return;
		case "neko":
			if( !Context.defined("neko") ) return;
		case "js":
			if( !Context.defined("js") ) return;
		case "cpp":
			if( !Context.defined("cpp") ) return;
		case "flash8":
			if( !Context.defined("flash") || Context.defined("flash9") ) return;
		case "flash":
			if( !Context.defined("flash9") ) return;
		case "mt","mtwin":
			return;
		case "sys":
			if( !Context.defined("neko") && !Context.defined("php") && !Context.defined("cpp") ) return;
		case "java":
			if( !Context.defined("java") ) return;
		case "cs":
			if( !Context.defined("cs") ) return;
		case "tools":
			return;
		case "build-tool":
			return;
		}
		addPackage('jabber');
		addPackage('xmpp');

		/*
		for( p in Context.getClassPath() ) {
			if( p == "/" )
				continue;
			// skip if we have a classpath to haxe
			if( pack.length == 0 && sys.FileSystem.exists(p+"std") )
				continue;
			var p = p + pack.split(".").join("/");
			if( StringTools.endsWith(p,"/") )
				p = p.substr(0,-1);
			if( !sys.FileSystem.exists(p) || !sys.FileSystem.isDirectory(p) )
				continue;
			for( file in sys.FileSystem.readDirectory(p) ) {
				if( file == ".git" || file.startsWith( '_' ) )
					continue;
				var full = (pack == "") ? file : pack + "." + file;
				if( StringTools.endsWith(file, ".hx") ) {
					var cl = full.substr(0, full.length - 3);
					if( StringTools.startsWith(cl,"flash8.") )
						cl = "flash."+cl.substr(7);
					switch( cl ) {
					case "ImportAll", "neko.db.MacroManager": continue;
					case "haxe.TimerQueue": if( Context.defined("neko") || Context.defined("php") || Context.defined("cpp") ) continue;
					case "Sys": if( !(Context.defined("neko") || Context.defined("php") || Context.defined("cpp")) ) continue;
					case "haxe.web.Request": if( !(Context.defined("neko") || Context.defined("php") || Context.defined("js")) ) continue;
					case "haxe.macro.ExampleJSGenerator","haxe.macro.Context", "haxe.macro.Compiler": if( !Context.defined("neko") ) continue;
					case "haxe.remoting.SocketWrapper": if( !Context.defined("flash") ) continue;
					case "haxe.remoting.SyncSocketConnection": if( !(Context.defined("neko") || Context.defined("php") || Context.defined("cpp")) ) continue;
					}
					Context.getModule(cl);
				} else if( sys.FileSystem.isDirectory(p + "/" + file) )
					run(full);
			}
		}
		*/
	}
}