package xmpp.macro;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import xmpp.xml.Schema;

using StringTools;
using haxe.macro.ComplexTypeTools;

/*
TODO:
	- constructor args are all optional!
	- enum tokens
	- restricted string check
	- add schema docs
	- extract xep nr from schema doc and add it as @xep(23)
*/


class ContentType {

	public static function fromSchema( schema : Schema, pack : Array<String>, module : String ) : Array<TypeDefinition> {
		var gen = new Gen();
		var types = gen.build( schema, pack, module );
		return types;
	}
}

private class Gen {

	static var KWDS = ['class','continue','switch','var'];

	var schema : Schema;

	public function new() {}

	public function build( schema : Schema, pack : Array<String>, module : String ) : Array<TypeDefinition> {
		
		this.schema = schema;

		var types = new Array<TypeDefinition>();

		var doc : String = null;
		//var xep : Int;

		if( schema.annotation != null ) {
			switch schema.annotation.content {
			case appinfo(v): trace(v);
			case documentation(v):
				doc = v.content;
				//trace(doc);
				//var expr = ~/XEP-(0030)/;
			}
		}

		for( e in schema.elements ) {

//			if( e.name != 'text') continue;
			//trace(e);

			if( e.complexType == null ) {
				
				var t = getComplexType(e.type);
				//trace(e.name,e.type,t);
				var typeName = escapeTypeName( e.name );
				/*
				var type : TypeDefinition = {
					pack: [],
					name: typeName,
					kind: TDAlias( macro:String ),
					pos: null,
					fields: []
				};
				types.push( type );
				*/
				var typeAbstract : TypeDefinition = {
					name: typeName,
					pack: [],
					//kind: TDAbstract( TPath( { pack: typeDefinition.pack, name: typeDefinition.name, params: [] } ) ),
					kind: TDAbstract( macro:xmpp.XML, [macro:xmpp.XML], [macro:xmpp.XML]),
					pos: null,
					fields: [],
					//meta: [{ name: ":forward", pos: null }]
				};
				types.push( typeAbstract );


				continue;
				

			} else {

				var typeName = if( types.length == 0 ) module else escapeTypeName( e.name );
				//var typeName = escapeTypeName( e.name );
				var typePath = { pack: [], name: typeName, params: [] };
				var typeDefinitionFields = new Array<Field>();

				var typeAbstract : TypeDefinition = {
					name: typeName,
					pack: [],
					//kind: TDAbstract( TPath( { pack: typeDefinition.pack, name: typeDefinition.name, params: [] } ) ),
					kind: TDAbstract( TAnonymous(typeDefinitionFields) ),
					pos: null,
					fields: [],
					meta: [{ name: ":forward", pos: null }]
				};

				var constructorArgs = new Array<FunctionArg>();
				var constructorExprs = new Array<Expr>();
				var toXMLExprs = new Array<Expr>();
				var fromXMLExprs = new Array<Expr>();

				toXMLExprs.push( macro var x = xmpp.XML.create($v{e.name}) );
				fromXMLExprs.push( macro var o = new $typePath() );

							if( types.length == 0 ) {
						typeAbstract.fields.push({
							name: 'XMLNS',
							access: [APublic,AStatic,AInline],
							kind: FVar(macro:String, macro $v{schema.xmlns} ),
							pos: null
						});
						toXMLExprs.push( macro x.set( 'xmlns', XMLNS ) );
					}

				types.push( typeAbstract );

				if( e.complexType != null ) {

					if( e.complexType.attribute != null ) {
						for( a in e.complexType.attribute ) {
							var attrName = a.name;
							var fieldName = escapeFieldName( a.name );
							var fieldType = macro:String;
							//var fieldType = getComplexType( (a.type != null) ? a.type : e.name );
							var optional = a.use == 'optional';
							var field = {
								name: fieldName,
								kind: FVar( fieldType ),
								pos: null,
								meta: []
							};
							if( optional ) field.meta.push({ name: ':optional', pos: null });
							typeDefinitionFields.push( field );
							//constructorArgs.push({ name: fieldName, type: fieldType, opt: optional });
							toXMLExprs.push( macro if( this.$fieldName != null ) x.set( $v{attrName}, this.$fieldName ) );
							fromXMLExprs.push( macro o.$fieldName = x.get( $v{attrName} ) );
						}
					}

					if( e.complexType.simpleContent != null ) {
						if( e.complexType.simpleContent.extension != null ) {
							for( a in e.complexType.simpleContent.extension.attribute ) {
								var attrName = (a.ref != null) ? a.ref : a.name;
								var fieldName = escapeFieldName( attrName );
								var fieldType = getComplexType( (a.type != null) ? a.type : a.ref );
								trace(attrName,fieldName);
								//var attrName = a.name; //(a.ref != null) ? a.ref : a.name;
								//var fieldName = escapeFieldName( attrName );
								//var fieldType = getComplexType( a.type );
								var optional = a.use == 'optional';
								var field = {
									name: fieldName,
									kind: FVar( macro:String ),
									pos: null,
									meta: []
								};
								if( optional ) field.meta.push({ name: ':optional', pos: null });
								typeDefinitionFields.push( field );
								toXMLExprs.push( macro if( this.$fieldName != null ) x.set( $v{attrName}, this.$fieldName ) );
								fromXMLExprs.push( macro o.$fieldName = x.get( $v{attrName} ) );
							}
						}
					}

					if( e.complexType.sequence != null ) {
						var optional = true; //minOccurs == '0';
						var fromXMLswitchExprCases = new Array<Case>();
						for( e in e.complexType.sequence.elements ) {
							var attrName = (e.ref != null) ? e.ref : e.name;
							var fieldName = escapeFieldName( attrName );
							var fieldType = getComplexType( (e.type != null) ? e.type : e.ref );
							var isArray = true; //e.maxOccurs == 'unbounded';
							if( isArray ) fieldType = TPath( { name: 'Array<${fieldType.toString()}>', pack: [] } );
							var field = {
									name: fieldName,
									kind: FVar( fieldType ),
									pos: null,
									meta: []
							};
							if( optional ) field.meta.push({ name: ':optional', pos: null });
							typeDefinitionFields.push( field );
							if( isArray ) {
								constructorExprs.push( macro if( $i{fieldName} == null ) $i{fieldName} = [] );
								toXMLExprs.push( macro if( this.$fieldName != null ) for( e in this.$fieldName ) x.append( e ) );
								fromXMLswitchExprCases.push({expr: macro o.$fieldName.push(e), values:[ macro $v{fieldName}] });
							} else {
								toXMLExprs.push( macro if( this.$fieldName != null ) x.append( xmpp.XML.create( $v{fieldName}, this.$fieldName ) ) );
								fromXMLswitchExprCases.push({expr: macro o.$fieldName = e.text, values:[ macro $v{fieldName}] });
							}
						}
						var switchExpr = ESwitch( macro e.name, fromXMLswitchExprCases, null ) ;
						var forExpr = macro {};
						fromXMLExprs.push( { expr: EFor( macro e in x.elements, { expr: switchExpr, pos: null } ), pos: null } );
					}

					if( e.complexType.choice != null ) {
						for( e in e.complexType.choice.elements ) {
							trace(">>>>>>>>>>>>>>>>>>>>>>>>>s");
							trace(e.name);
						}
					}
				}

				for( f in typeDefinitionFields ) {
					switch f.kind {
					case FVar(t,e):
						var fieldName = f.name;
						constructorArgs.push({ name: f.name, type: t, opt: true }); //TODO: optional
						//constructorArgs.push({ name: f.name, type: t, opt: f.meta.length > 0 });
						//toXMLExprs.push( macro if( this.${f.name} != null ) x.set( $v{f.name}, this.${f.name} ) );
						//toXMLExprs.push( macro if( this.$f.$name != null ) x.set("a","a") );
					default:
					}
				}

				var objFields : Array<ObjectField> = typeDefinitionFields.map(
					//f -> return { field: f.name, expr: macro ($i{f.name}!=null) ? $i{f.name} : [], quotes: null }
					f -> return { field: f.name, expr: macro $i{f.name}, quotes: null }
				);
				var objDecl = { expr: EObjectDecl( objFields ), pos: null };
				constructorExprs.push( macro this = $objDecl );

				typeAbstract.fields.push({
					name: 'new',
					access: [APublic,AInline],
					kind: FFun({
						ret: macro:Void,
						expr: { expr: EBlock( constructorExprs ), pos: null },
						args: constructorArgs
					}),
					pos: null
				});

				toXMLExprs.push( macro return x );

				typeAbstract.fields.push({
					name: 'toXML',
					access: [APublic],
					kind: FFun({
						args: [],
						ret: macro:xmpp.XML,
						expr: { expr: EBlock( toXMLExprs ), pos: null },
					}),
					meta: [{ name: ':to', pos: null }],
					pos: null
				});

				fromXMLExprs.push( macro return o );

				typeAbstract.fields.push({
					name: 'fromXML',
					access: [APublic,AStatic],
					kind: FFun({
						args: [{ name: 'x', type: macro: xmpp.XML  }],
						ret: TPath( { pack: pack, name: typeName, params: [] } ),
						expr: { expr: EBlock( fromXMLExprs ), pos: null },
					}),
					meta: [{ name: ':from', pos: null }],
					pos: null
				});
			}
		}

		return types;
	}

	function getComplexType( name : String ) : haxe.macro.ComplexType {
		switch name {
		case 'xs:string':
			return macro : String;
		case 'xs:positiveInteger':
			return macro : String;
		case 'xs:dateTime':
			return macro : String;
		case 'xs:int':
			return macro : String;
		case 'xs:boolean':
			//return macro : Bool; //TODO
			return macro : String;
		case 'xs:NMTOKEN':
			return macro : String;
		case 'xs:NMTOKENS':
			return macro : String;
		default:
			for( e in schema.simpleType ) {
				if( e.name == name ) {
					//trace("FOUND SIMPLE TYPÜE");
					//trace(e.restriction[0].base);
					return getComplexType( e.restriction[0].base );
					//return macro:String;
				}
			}
			trace("????????????? UNKNOWN TyPE "+name);
			if( name == null ) {
				return macro:String;
			}
			return TPath( { pack: [], name: escapeTypeName( name ), params: [] } );
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

	static function capitalize( str : String ) : String {
        return str.charAt( 0 ).toUpperCase() + str.substr( 1 );
    }

}

#end
