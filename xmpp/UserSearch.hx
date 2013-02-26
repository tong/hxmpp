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

using xmpp.XMLUtil;

class UserSearch {
	
	public static var XMLNS(default,null) : String = "jabber:iq:search";
	
	public var instructions : String;
	public var first : String;
	public var last : String;
	public var nick : String;
	public var email : String;
	public var items : Array<UserSearchItem>;
	public var form : DataForm;
	
	public function new() {
		items = new Array();
	}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS );
		x.addField( this, 'instructions' );
		x.addField( this, 'first' );
		x.addField( this, 'last' );
		x.addField( this, 'nick' );
		x.addField( this, 'email' );
		for( i in items ) {
			var e = Xml.createElement( "item" );
			e.set( "jid", i.jid );
			e.addChild( XMLUtil.createElement( "first", i.first ) );
			e.addChild( XMLUtil.createElement( "last", i.last ) );
			e.addChild( XMLUtil.createElement( "nick", i.nick ) );
			e.addChild( XMLUtil.createElement( "email", i.email ) );
			x.addChild( e );
		}
		if( form != null ) x.addChild( form.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : UserSearch {
		var s = new UserSearch();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "instructions" : s.instructions = e.firstChild().nodeValue;
			case "first" : s.first = getFieldValue( e );
			case "last" : s.last = getFieldValue( e );
			case "nick" : s.nick = getFieldValue( e );
			case "email" : s.email = getFieldValue( e );
			case "item" :
				var i : UserSearchItem = cast { jid : e.get( "jid" ) };
				for( c in e.elements() ) {
					switch( c.nodeName ) {
					case "first" :  i.first = c.firstChild().nodeValue;
					case "last" :  i.last = c.firstChild().nodeValue;
					case "nick" :  i.nick = c.firstChild().nodeValue;
					case "email" :  i.email = c.firstChild().nodeValue;
					}
				}
				s.items.push( i );
			case "x" : s.form = DataForm.parse( e );
			}
		}
		return s;
	}
	
	static function getFieldValue( x : Xml ) : String {
		return ( x.firstChild() == null ) ? "" : x.firstChild().nodeValue;
	}
	
}
