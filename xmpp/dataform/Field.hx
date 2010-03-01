/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package xmpp.dataform;

import xmpp.XMLUtil;

class Field {
	
	public var label : String;
	public var type : FieldType;
	public var variable : String;
	public var desc : String;
	public var required : Bool;
	public var values : Array<String>;
	public var options : Array<FieldOption>;
	
	public function new( ?type : FieldType ) {
		this.type = type;
		values = new Array();
		options = new Array();
		required = false;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "field" );
		if( label != null ) x.set( "label", label );
		if( type != null ) x.set( "type", StringTools.replace( Type.enumConstructor( type ), "_", "-" ) );
		if( variable != null ) x.set( "var", variable );
		if( required ) x.addChild( XMLUtil.createElement( "required" ) );
		if( desc != null ) x.addChild( XMLUtil.createElement( "desc", desc ) );
		for( value in values ) x.addChild( XMLUtil.createElement( "value", value ) );
		for( option in options ) x.addChild( option.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Field  {
		var f = new Field();
		if( x.exists( "label" ) ) f.label = x.get( "label" );
		if( x.exists( "type" ) ) f.type = Type.createEnum( FieldType, StringTools.replace( x.get( "type" ), "-", "_" ) );
		if( x.exists( "var" ) ) f.variable = x.get( "var" );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "desc" : try { f.desc = e.firstChild().nodeValue; } catch( e : Dynamic ) {}
			case "required" : f.required = true;
			case "option" : f.options.push( FieldOption.parse( e ) );
			case "value" : try { f.values.push( e.firstChild().nodeValue ); } catch( e : Dynamic ) {}
			}
		}
		return f;
	}
	
	/**
		Parses all dataform fields into the given dataform field container.
	*/
	public static inline function parseFields( t : { fields : Array<Field> }, x : Xml ) : { fields : Array<Field> } {
		for( e in x.elementsNamed( "field" ) ) {
			t.fields.push( Field.parse( e.firstElement() ) );
		}
		return t;
	}
	
}
