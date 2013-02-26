/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
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
		this.type = ( type == null ) ? FieldType.text_single : type;
		values = new Array();
		options = new Array();
		required = false;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "field" );
		if( label != null ) x.set( "label", label );
		if( type != null ) x.set( "type", StringTools.replace( Type.enumConstructor( type ), "_", "-" ) );
		if( variable != null ) x.set( "var", variable );
		if( required ) x.addChild( Xml.createElement( "required" ) );
		if( desc != null ) x.addChild( XMLUtil.createElement( "desc", desc ) );
		for( v in values ) x.addChild( XMLUtil.createElement( "value", v ) );
		for( o in options ) x.addChild( o.toXml() );
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
	public static function parseFields( t : { fields : Array<Field> }, x : Xml ) : { fields : Array<Field> } {
		for( e in x.elementsNamed( "field" ) ) {
			t.fields.push( Field.parse( e.firstElement() ) );
		}
		return t;
	}
	
}
