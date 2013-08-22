
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

using Lambda;
using StringTools;

/**
	Utility to build/clean all hxmpp examples
*/
class Build {

	static var PATH = ".";
	static var AUTOCLEAN_FILES = ['exe','jar','js','map','n','nodejs','php','swf'];
	static var AUTOCLEAN_DIRECTORIES = ['cpp','cs','java','lib','res'];

	static function build() {

		println('');

		// Determine examples to build
		var builds = new Array<String>();
		for( p in FileSystem.readDirectory( PATH ) ) {
			var path = PATH+"/"+p;
			if( FileSystem.isDirectory( path ) && !StringTools.startsWith( p, "_" ) &&
				FileSystem.exists( path+"/build.hxml" ) ) {
				builds.push( p );
			}
		}
		if( builds.length == 0 ) {
			println( "Nothing to build" );
			return;
		}
		builds.sort( function(a,b) return if( a > b ) 1 else if( a < b ) -1 else 0 );

		// Build all
		println( "    Building "+builds.length+" examples ...\n" );
		var failedBuilds = new Array<String>();
		var numBuilded = 0;
		var i = 0;
		for( p in builds ) {
			var n = (i+1);
			var spaces = "";
			for( i in 0...(10-Std.string(n).length) )
				spaces += " ";
			print( spaces+n+" : "+p );
			var rootPath = Sys.getCwd();
			Sys.setCwd( PATH+"/"+p );
			//TODO add hxcpp 64 bit flag
			var hx = new Process( "haxe", ["build.hxml"] );
			var err = hx.stderr.readAll().toString();
			var res = hx.stdout.readAll().toString();
			if( err == null || err == "" ) {
				numBuilded++;
				println( " : ok : "+res, "ok" );
				//println( res );
			} else {
				trace(err);
				var info = err;
				while( StringTools.startsWith( info, "../" ) )
					info = info.substr(3);
				println( " : FAILED ", "error" );
				print( info, "error" );
				failedBuilds.push( p );
			}
			Sys.setCwd( rootPath );
			i++;
		}
		println( "" );
		println( "    "+numBuilded+" OK", "ok" );
		//print( " | " );
		println( "    "+failedBuilds.length+" FAILED" ); 
		if( failedBuilds.length > 0 )
			println( '        ( '+failedBuilds.join(", ")+' )\n', "error" );
		println( "" );
	}

	static function clean() {
		for( f in FileSystem.readDirectory( PATH ) ) {
			var p = '$PATH/$f';
			if( f.startsWith( "_" ) ||  !FileSystem.isDirectory( p ) || !FileSystem.exists( p+"/build.hxml" ) )
				continue;
			for( f in FileSystem.readDirectory( p ) ) {
				var fpath = p+"/"+f;
				if( FileSystem.isDirectory( fpath ) ) {
					if( AUTOCLEAN_DIRECTORIES.has(f) ) {
						deleteDirectory( fpath );
					}
				} else {
					if( isFileType( f, AUTOCLEAN_FILES ) ) {
						FileSystem.deleteFile( fpath );
					}
				}
			}
		}
	}

	static function deleteDirectory( path : String, n : Int = 0 ) {
		for( f in FileSystem.readDirectory( path ) ) {
			var p = '$path/$f';
			FileSystem.isDirectory( p ) ? deleteDirectory(p) : FileSystem.deleteFile(p);
		}
		FileSystem.deleteDirectory( path );
	}

	static function isFileType( s : String, types : Array<String> ) : Bool {
		for( type in types )
			if( s.endsWith( type ) )
				return true;
		return false;
	}

	static inline function print( t : Dynamic, ?level : String ) Sys.print( t );
	static inline function println( t : Dynamic, ?level : String ) Sys.println( t );

	static function main() {
		switch( Sys.args()[0] ) {
		case "clean": clean();
		default: build();
		}
	}

}
