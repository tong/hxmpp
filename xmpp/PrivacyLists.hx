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

/**
*/
class PrivacyLists {
	
	public static var XMLNS(default,null) : String = "jabber:iq:privacy";
	
	public var active : String;
	public var _default : String;
	public var lists : Array<xmpp.PrivacyList>;

	public function new() {
		lists = new Array();
	}
	
	public function toXml() : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		if( active != null ) {
			var e = Xml.createElement( "active" );
			if( active != "" ) e.set( "name", active );
			x.addChild( e );
		}
		if( _default != null ) {
			var e = Xml.createElement( "default" );
			e.set( "name", _default );
			x.addChild( e );
		}
		for( l in lists )
			x.addChild( l.toXml() );
		return x;
	}
	
	public inline function iterator() : Iterator<PrivacyList> {
		return lists.iterator();
	}
	
	public static function parse( x : Xml ) : xmpp.PrivacyLists {
		var p = new xmpp.PrivacyLists();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
				case "active" : p.active = e.get( "name" );
				case "default" : p._default = e.get( "name" );
				case "list" : p.lists.push( xmpp.PrivacyList.parse( e ) );
			}
		}
		return p;
	}
	
}
