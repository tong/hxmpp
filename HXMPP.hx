
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
		var args = Sys.args();
		var path = args.pop();
		switch args[0] {
		case 'build', null: build();
		default:
		}
	}

	static function build() {

		for( module in [
			//{ name : 'xep.disco.Info', file : 'xsd/disco-info.xsd' },
			//{ name : 'xep.Roster', file : 'xsd/roster.xsd' },
			//{ name : 'xep.ChatState', file : 'xsd/chatstates.xsd' },
			//{ name : 'xep.EntityTime', file : 'xsd/time.xsd' },
			//{ name : 'xep.SASL', file : 'xsd/sasl.xsd' },
			//{ name : 'xep.Ping', file : 'xsd/ping.xsd' }
			//{ name : 'xep.EntityCapabilities', file : 'xsd/caps.xsd' }
			//{ name : 'xep.PubSubCapabilities', file : 'xsd/pubsub.xsd' }
			//{ name : 'xep.AvataData', file : 'xsd/avatar-data.xsd' },
			//{ name : 'xep.AvataMetadata', file : 'xsd/avatar-metadata.xsd' }
			{ name : 'xep.Blocking', file : 'xsd/blocking.xsd' },
			{ name : 'xep.PrivateStorage', file : 'xsd/iq-private.xsd' }
		] ) {
			
			var name = module.name;
			var pack = name.split('.');
			if( pack.length > 0 ) name = pack.pop();
			var schema = Schema.parse( XML.parse( File.getContent( module.file ) ) );
			var types = new Array<TypeDefinition>();
		
			for( e in schema.elements ) {
				var typeName = types.length == 0 ? name : null;
				var xmlns = ( types.length == 0
					|| schema.xmlns_xml == 'http://www.w3.org/XML/1998/namespace' //TODO: ?
					) ? schema.xmlns : null;
				var elementTypes = buildElement( e, null, xmlns );
				//var elementTypes = buildElement( e, typeName, xmlns );
				types = types.concat( elementTypes );

			}

			/* types.unshift({
				name: name,
				pack: [],
				kind: TDClass(),
				pos: null,
				fields: []
			});
 */
			for( e in schema.simpleType ) {

				trace(e.name+' ----------------------------------------------');
				trace(e.restriction[0].minLength);

				var type = macro:String;
 
				//for( restriction in e.restriction )

				/*
				var constructorArgs = new Array<FunctionArg>();
				var constructorExprs = new Array<Expr>();

				constructorArgs.push({
					name: 's',
					type: type,
				});

				if( e.restriction[0] != null ) {
						trace("LLLLLLLLLLLLLLLLLLLLLLL",e.restriction[0] );
					if( e.restriction[0].minLength != null ) {
						constructorExprs.push( macro if( s.length < minLength ) throw 'invalid length' );
					} 
					/*
					if( e.restriction[0].enumeration.length == 1 ) {
					}
					* /
				}

				constructorExprs.push( macro this = s );

				var abs = {
					name: escapeTypeName( e.name ),
					kind: TDAbstract(type,[type],[type]),
					pack: [],
					fields: [],
					pos: null
				};
				
				abs.fields.push({
					access: [APublic,AInline],
					name: 'new',
					pos: null,
					kind: FFun({
						args: constructorArgs,
						ret:  macro: Void,
						expr: { expr: EBlock( constructorExprs ), pos: null }
					}),
				});

				types.push( abs );
				*/

				/*
				var abs = {
					name: escapeTypeName( e.name ),
					kind: TDAbstract(type,[type],[type]),
					pack: [],
					fields: [],
					pos: null,
					meta: []
				};
				if( e.restriction[0] != null ) {
					if( e.restriction[0].enumeration.length > 0 ) {
						abs.meta.push({ name: ':enum', pos: null });
						for( en in e.restriction[0].enumeration ) {
							var name = en.value;
							if( name.length == 0 ) name = '_';
							abs.fields.push({
								access: [],
								name: name,
								kind: FVar(macro:String, macro $v{en.value}),
								pos: null,
							});
						}
					}
				}
				types.push( abs );
				*/
			}

			if( schema.annotation != null ) {
				switch schema.annotation.content {
				case appinfo(v): trace(v);
				case documentation(v):
					var doc = v.content.split('\n').map( l -> return l.trim() ).join(' '); //.replace('\n','');
					for( t in types ) {
						switch t.kind {
						case TDAbstract(a,from,to):
							t.doc = doc;
							break;
						default:
						}
					}
				}
			}

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

	static function buildElement( e : xmpp.xml.Schema.Element, ?name : String, ?xmlns : String ) : Array<TypeDefinition> {
		
		if( name == null ) name = escapeTypeName( e.name );

		var types = new Array<TypeDefinition>();
		var typeName = escapeTypeName( name );
		var typePath = { pack: [], name: typeName, params: [] };
		var typedefName = typeName+'Type';
		var typedefPath = TPath({name: typedefName, pack: []});

		var constructorArgs = new Array<FunctionArg>();
		var constructorExprs = new Array<Expr>();
		//var toXMLField =
		var toXMLExprs : Array<Expr> = [macro var x = xmpp.XML.create($v{e.name})];
		var fromXMLExprs : Array<Expr> = []; //[macro var o = new $typePath()];
		
		var abs : TypeDefinition = cast {
			name: typeName,
			pack: [],
			//kind: TDAbstract( atype, [atype], [atype] ),
			pos: null,
			fields: []
		
		};

		 if( xmlns != null ) {
			abs.fields.unshift({
				name: 'XMLNS',
				access: [APublic,AStatic,AInline],
				kind: FVar(macro:String, macro $v{xmlns} ),
				pos: null
			});
			toXMLExprs.push( macro x.set( 'xmlns', XMLNS ) );
			//fromXMLExprs.push( macro if( x.get( 'xmlns' ) != XMLNS ) return  null);
		}

		/* if( types.length == 0 ) {
				abs.fields.push({
					name: 'XMLNS',
					access: [APublic,AStatic,AInline],
					//kind: FVar(macro:String, macro $v{schema.xmlns} ),
					kind: FVar(macro:String, macro 'FUCK' ),
					pos: null
				});
				toXMLExprs.push( macro x.set( 'xmlns', XMLNS ) );
			} */
			
		
		if( e.complexType == null ) {

			var atype = getComplexType( e.type );
			abs.kind = TDAbstract( atype, [atype], [atype] );
		
			toXMLExprs.push( macro x.text = Std.string( this ) );
			toXMLExprs.push( macro return x );
			fromXMLExprs.push( macro return cast x.text );

			types.push( abs );
			
		} else {

			var typeDefinitionFields = new Array<Field>();

			types.push({
				name: typedefName,
				kind: TDStructure,
				pos: null,
				pack: [],
				fields: typeDefinitionFields
			});

			abs.kind = TDAbstract( typedefPath, [] );
			abs.meta = [{ name: ":forward", pos: null }];

			types.push( abs );
			
			//fromXMLExprs.push( macro var o = new $typePath() ); 
			//fromXMLExprs.push( macro var o : $typedefPath = cast {} );
			fromXMLExprs.push( macro var o = new $typePath() );
 
			constructorExprs.push( macro this = (t != null) ? t : cast {} );

			//constructorExprs.push( if( t == null ) t = {} );
			//constructorExprs.push( macro this = t );

			function buildAttribute( a : Attribute ) {
				var name = (a.ref != null) ? a.ref : a.name;
				var fieldName = escapeFieldName( name );
				var fieldType = macro:String;
				//var fieldType : haxe.macro.ComplexType = null;
				if( a.type == null ) {
					if( a.simpleType != null ) {
						switch a.simpleType.restriction[0].base {
						case 'xs:NMTOKEN':
							var fields = new Array<Field>();
							for( e in a.simpleType.restriction[0].enumeration ) {
								fields.push({
									name: escapeFieldName( e.value ),
									kind: FVar(macro:String, macro $v{e.value}),
									pos: null,
								});
							}
							var name = capitalize( fieldName );
							types.push({
								name: name,
								//TODO: kind: TDAbstract(macro:String,[],[macro:String]),
								kind: TDAbstract(macro:String,[macro:String],[macro:String]),
								pos: null,
								pack: [],
								fields: fields,
								meta: [{ name: ':enum', pos: null }]
							});
							fieldType = TPath({ name: name, pack: [] });
						}
					}
				} else {
					//fieldType = getComplexType( a.type );
				}
				var optional = a.use == 'optional';
				typeDefinitionFields.push( {
					name: fieldName,
					kind: FVar( fieldType ),
					pos: null,
					meta: optional ? [{ name: ':optional', pos: null }] : []
				} );
				toXMLExprs.push( macro if( this.$fieldName != null ) x.set( $v{a.name}, this.$fieldName ) );
				fromXMLExprs.push( macro o.$fieldName = x.get( $v{a.name} ) );
			}

			if( e.complexType.attribute != null ) {
				for( a in e.complexType.attribute ) {
					buildAttribute( a );
				}
			}

			if( e.complexType.simpleContent != null ) {
				if( e.complexType.simpleContent.extension != null ) {
					for( a in e.complexType.simpleContent.extension.attribute ) {
						buildAttribute( a );
					}
				}
			}

			if( e.complexType.sequence != null ) {
				var fromXMLswitchExprCases = new Array<Case>();
				for( e in e.complexType.sequence.elements ) {
					var fieldName = escapeFieldName( (e.ref != null) ? e.ref : e.name );
					var fieldType = getComplexType( (e.type != null) ? e.type : e.ref );
					var optional = false;
					var isArray = true; 
					if( isArray ) fieldType = TPath( { name: 'Array<${fieldType.toString()}>', pack: [] } );
					typeDefinitionFields.push( {
						name: fieldName,
						kind: FVar( fieldType ),
						pos: null,
						meta: optional ? [{ name: ':optional', pos: null }] : []
					} );
					if( isArray ) {
						constructorExprs.push( macro if( this.$fieldName == null ) this.$fieldName = [] );
						toXMLExprs.push( macro if( this.$fieldName != null ) for( e in this.$fieldName ) x.append( e ) );
						fromXMLswitchExprCases.push({expr: macro o.$fieldName.push(e), values:[ macro $v{fieldName}] });
					} else {
						toXMLExprs.push( macro if( this.$fieldName != null ) x.append( xmpp.XML.create( $v{fieldName}, this.$fieldName ) ) );
						fromXMLswitchExprCases.push({expr: macro o.$fieldName = e.text, values:[ macro $v{fieldName}] });
					}
				}
				var switchExpr = ESwitch( macro e.name, fromXMLswitchExprCases, null ) ;
				fromXMLExprs.push( { expr: EFor( macro e in x.elements, { expr: switchExpr, pos: null } ), pos: null } );
			}

			toXMLExprs.push( macro return x );
			fromXMLExprs.push( macro return o );

			abs.fields.push({
				name: 'new',
				access: [APublic,AInline],
				kind: FFun({
					ret: macro:Void,
					expr: { expr: EBlock( constructorExprs ), pos: null },
					args: [{
						name: 't',
						type: typedefPath,
						opt: true
					}]
				}),
				pos: null
			});
		}

		abs.fields.push({
			name: 'toXML',
			access: [APublic,AInline],
			kind: FFun({
				args: [],
				ret:  macro: xmpp.XML,
				expr: { expr: EBlock( toXMLExprs ), pos: null }
			}),
			meta: [{name:':to',pos:null}],
			pos: null
		});

		abs.fields.push({
			name: 'fromXML',
			access: [APublic,AStatic,AInline],
			kind: FFun({
				args: [{ name: 'x', type: macro: xmpp.XML  }],
				ret: TPath( { pack: [], name: abs.name, params: [] } ),
				expr: { expr: EBlock( fromXMLExprs ), pos: null }
			}),
			meta: [{name:':from',pos:null}],
			pos: null
		});

		return types;
	}

	static function getComplexType( type : String ) : Null<haxe.macro.ComplexType> {
		return switch type {
		case null: null;
		case
			'xs:base64Binary',
			'xs:boolean',
			'xs:dateTime',
			'xs:int',
			'xs:positiveInteger',
			'xs:string',
			'xs:NMTOKEN','xs:NMTOKENS': macro: String;
		default:
			TPath( { pack: [], name: escapeTypeName( type ), params: [] } );
		}
	}

	static function escapeFieldName( name : String ) : String {
		name = name.replace( 'xml:', '' ); //TODO:
		name = name.replace( ':', '_' );
        name = name.replace( '-', '_' );
        return (KWDS.indexOf( name ) != -1) ? name + '_' : name;
    }

	static function escapeTypeName( name : String ) : String {
        name = name.replace( ':', '_' );
        name = name.replace( '-', '_' );
        return capitalize( name );
    }

	static inline function capitalize( str : String ) : String {
        return str.charAt( 0 ).toUpperCase() + str.substr( 1 );
    }

	////////////////////////////////////////////////////////////




	/*
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
				Sys.println(code+'\n');
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
		
		//buildScheme( 'disco-info', 'DiscoInfo' );
		// buildScheme( 'disco-items', 'DiscoItems' );
		// buildScheme( 'roster', 'Roster' );
		// buildScheme( 'sasl', 'SASL' );
		// buildScheme( 'tls', 'StartTLS' );
		//buildScheme( 'bind', 'Bind' );
		//buildScheme( 'session', 'Session' );

		// // buildScheme( 'caps', 'Caps' );
		buildScheme( 'time', 'EntityTime' );
		// buildScheme( 'ping', 'Ping' );
		//buildScheme( 'avatar-data', 'AvatarData' );
	//	buildScheme( 'avatar-metadata', 'AvatarMeta' );

		//buildScheme( 'pubsub', 'PubSub' );

		// me( 'buildScheme( 'muc', ['xep','muc'], 'MUC' );
		// buildScheme( 'muc-admi1n', ['xep','muc'], 'Admin' );
		// buildScheme( 'muc-owner', ['xep','muc'], 'Owner' );
		// buildSchemuc-user', ['xep','muc'], 'User' );

		//buildScheme( 'jingle', ['xep'], 'Jingle' );
		//buildScheme( 'jingle-transports-s5b', ['xep','jingle'], 'FileTransfer' );
	}
	*/


}
