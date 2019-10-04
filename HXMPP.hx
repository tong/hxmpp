
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import sys.FileSystem;
import sys.io.File;
import xmpp.XML;
import xmpp.macro.ContentType;
import xmpp.xml.Schema;

using StringTools;
using haxe.macro.ComplexTypeTools;

class HXMPP {

	static var KWDS = ['class','continue','switch','var'];

	static function main() {
		/*
		var args = Sys.args();
		var path = args.pop();
		switch args[0] {
		case 'build', null: //build();
		default:
		}
		*/
	}

	static function build( module : String, xsdFile : String ) {

		var name = module;
		var pack = name.split('.');
		if( pack.length > 0 ) name = pack.pop();
		var schema = Schema.parse( XML.parse( File.getContent( xsdFile ) ) );
		var types = xmpp.macro.ContentType.buildModule( name, schema );
		//trace(types.length);

		var dir = 'src/'+pack.join('/');
		var tmp = '';
		for( d in dir.split( '/' ) ) {
			tmp += d+'/';
			if( !FileSystem.exists( tmp ) ) FileSystem.createDirectory( tmp );
		}
		var printer = new haxe.macro.Printer();
		var file = File.write( '$dir/$name.hx' );
		file.writeString( 'package '+pack.join('.')+';\n\n' );
		for( t in types ) {
			var code = printer.printTypeDefinition( t )+'\n';
			Sys.println(code);
			file.writeString( code );
		}
		file.close();
	}

}
