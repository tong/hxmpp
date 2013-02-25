/*
 * Copyright (c) disktree.net
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

class PrivacyList {
	
	public var name : String;
	public var items : Array<xmpp.privacylist.Item>;
	
	public function new( name : String ) {
		this.name = name;
		items = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "list" );
		x.set( "name", name );
		for( i in items )
			x.addChild( i.toXml() );
		return x;	
	}
	
	public static function parse( x : Xml ) : xmpp.PrivacyList {
		var p = new xmpp.PrivacyList( x.get( "name" ) );
		for( e in x.elementsNamed( "item" ) )
			p.items.push( xmpp.privacylist.Item.parse( e ) );
		return p;
	}
	
}
