
#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import sys.FileSystem;
import sys.io.File;
import xmpp.XML;
import xmpp.macro.ContentType;

using StringTools;

class HXMPP {


	static function build() {
		
		var xsdPath = 'res/xsd';
		var defaultPack = ['xep'];
		//var dst = 'src';

		var printer = new haxe.macro.Printer();

		function buildScheme( xsd : String, ?pack : Array<String>, module : String ) {

			if( xsd.indexOf('.')==-1 ) xsd += '.xsd';
			if( pack == null ) pack = defaultPack;

			var schema = xmpp.xml.Schema.parse( Xml.parse( File.getContent( '$xsdPath/$xsd' ) ).firstElement() );
			var types = xmpp.macro.ContentType.fromSchema( schema, pack, module );
		
			//Sys.println( module+', '+types.length+' types');

			var moduleCode = "";
			for( t in types ) {
				var code = printer.printTypeDefinition( t );
				//Sys.println(code+'\n');
				moduleCode += code+'\n\n';
			}
			
			var path = 'src/'+pack.join('/');

			var testDir = new Array<String>();
			for( dir in path.split('/') ) {
				testDir.push( dir );
				var p = testDir.join('/');
				if( !FileSystem.exists( p ) ) FileSystem.createDirectory(p);
			}

			path += '/$module.hx';
			File.saveContent( path, 'package '+pack.join('.')+';\n\n$moduleCode\n' );
		}
		
		//buildScheme( 'disco-info', 'DiscoInfo' );
		// buildScheme( 'iq-version', ['xep'], 'SoftwareVersion' );
		// buildScheme( 'iq-last', ['xep'], 'LastActivity' );
		// buildScheme( 'iq-register', ['xep'], 'Register' );
		//buildScheme( 'roster', 'Roster' );
		// buildScheme( 'muc', ['xep'], 'MUC' );
		// buildScheme( 'sasl', ['xep'], 'SASL' );
		 //buildScheme( 'time', 'EntityTime' );
		// buildScheme( 'bind', ['xep'], 'Bind' );
		// buildScheme( 'ping', ['xep'], 'Ping' );
		//buildScheme( 'caps', ['xep'], 'Caps' );
		
		buildScheme( 'disco-info', 'DiscoInfo' );
		buildScheme( 'disco-items', 'DiscoItems' );
		buildScheme( 'roster', 'Roster' );
		buildScheme( 'sasl', 'SASL' );
		buildScheme( 'tls', 'StartTLS' );
		buildScheme( 'bind', 'Bind' );

		// buildScheme( 'caps', 'Caps' );
		buildScheme( 'time', 'EntityTime' );
		// buildScheme( 'ping', 'Ping' );

		// me( 'buildScheme( 'muc', ['xep','muc'], 'MUC' );
		// buildScheme( 'muc-admin', ['xep','muc'], 'Admin' );
		// buildScheme( 'muc-owner', ['xep','muc'], 'Owner' );
		// buildSchemuc-user', ['xep','muc'], 'User' );

		//buildScheme( 'jingle', ['xep'], 'Jingle' );
		//buildScheme( 'jingle-transports-s5b', ['xep','jingle'], 'FileTransfer' );
	}

}

#end
