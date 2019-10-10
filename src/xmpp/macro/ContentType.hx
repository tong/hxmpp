package xmpp.macro;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import xmpp.xml.Schema;

using StringTools;
using haxe.macro.ComplexTypeTools;

class ContentType {

	static var KWDS = ['class','continue','switch','var'];

	public static function buildModule( name : String, schema : Schema ) : Array<TypeDefinition> {
		
		var types = new Array<TypeDefinition>();

		for( e in schema.elements ) {
			var elementTypes = if( types.length == 0 ) {
				buildElement( e, name, schema.xmlns );
			} else {
				buildElement( e );
			}
			types = types.concat( elementTypes );
		}

		if( schema.annotation != null ) {
			switch schema.annotation.content {
			case appinfo(v): trace(v);
			case documentation(v):
				var doc = v.content.split('\n').map( l -> return l.trim() ).join(' '); //.replace('\n','');
				types[0].doc = doc;
				/*
				for( t in types ) {
					switch t.kind {
					case TDAbstract(a,from,to):
						t.doc = doc;
						break;
					default:
					}
				}
				*/
			}
		}

		return types;
	}
	
	static function buildElement( e : xmpp.xml.Schema.Element, ?name : String, ?xmlns : String ) : Array<TypeDefinition> {
		
		if( name == null ) name = escapeTypeName( e.name );
		//var name = escapeTypeName( e.name );

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

		/*
		if( moduleName != null ) {
			//toXMLExprs.push( macro x.set( 'xmlns', $v{xmlns} ) );
			toXMLExprs.push( macro x.set( 'xmlns', $i{moduleName}.XMLNS ) );
			//fromXMLExprs.push( macro if( x.get( 'xmlns' ) != XMLNS ) return  null);
		}
		*/
		
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
				toXMLExprs.push( macro if( this.$fieldName != null ) x.set( $v{name}, this.$fieldName ) );
				fromXMLExprs.push( macro o.$fieldName = x.get( $v{name} ) );
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
					switch e.complexType.simpleContent.extension.base {
					case 'xs:string':
						var fieldName = 'content';
						var fieldType = macro : String;
						typeDefinitionFields.push( {
							name: fieldName,
							kind: FVar( fieldType ),
							pos: null,
							//meta: optional ? [{ name: ':optional', pos: null }] : []
						} );
						toXMLExprs.push( macro x.text = this.$fieldName );
						fromXMLExprs.push( macro o.$fieldName = x.text );
					}
				}
			}

			if( e.complexType.sequence != null ) {
				if( e.complexType.sequence.elements != null ) {
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
				/*
				TODO
				if( e.complexType.sequence.choice != null ) {
					trace("CHOICE");
					trace(e.complexType.sequence.choice );
				}
				*/
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

}

#end
