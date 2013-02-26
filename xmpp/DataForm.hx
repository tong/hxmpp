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
package xmpp;

import xmpp.dataform.FormType;
using xmpp.XMLUtil;

/**
	DataForm packet extension (for iq and message packets).

	XEP-0004: Data Forms: http://xmpp.org/extensions/xep-0004.html
*/
class DataForm {
	
	public static var XMLNS(default,null) : String = "jabber:x:data";
	
	public var type : FormType;
	public var title : String;
	public var instructions : String;
	public var fields : Array<xmpp.dataform.Field>;
	public var reported : xmpp.dataform.Reported;
	public var items : Array<xmpp.dataform.Item>;
	
	public function new( ?type : FormType ) {
		this.type = ( type == null ) ? xmpp.dataform.FormType.result : type;
		fields = new Array();
		items = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "x" );
		x.ns( XMLNS );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		x.addField( this, 'title' );
		x.addField( this, 'instructions' );
		for( f in fields ) x.addChild( f.toXml() );
		if( reported != null ) x.addChild( reported.toXml() );
		for( i in items ) x.addChild( i.toXml() ); 
		return x;
	}
	
	public static function parse( x : Xml ) : DataForm {
		var f = new DataForm( Type.createEnum( xmpp.dataform.FormType, x.get( "type" ) ) );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "title" : f.title = e.firstChild().nodeValue;
			case "field" : f.fields.push( xmpp.dataform.Field.parse( e ) );
			case "item" : f.items.push( xmpp.dataform.Item.parse( e ) );
			case "instructions" : f.instructions = e.firstChild().nodeValue;
			case "reported" : f.reported = xmpp.dataform.Reported.parse( e );
			}
		}
		return f;
	}
	
}
