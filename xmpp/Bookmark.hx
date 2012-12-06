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

private typedef Conference = {
	var jid : String;
	var name : String;
	var nick : String;
	var autojoin : Null<Bool>;
	/** NOT RECOMMENDED */
	var password : String;
}

private typedef URL = {
	var name : String;
	var url : String;
}

class Bookmark {
	
	public static var XMLNS(default,null) : String = 'storage:bookmarks';
	
	public var conferences : Array<Conference>;
	public var urls : Array<URL>;
	
	public function new() {
		conferences = new Array();
		urls = new Array();
	}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS, 'storage' );
		for( c in conferences ) {
			var e = Xml.createElement( 'conference' );
			e.set( 'jid', c.jid );
			if( c.name != null ) e.set( 'name', c.name );
			if( c.autojoin != null ) e.set( 'autojoin', Std.string( c.autojoin ) );	
			e.addField( c, 'nick' );
			if( c.password != null ) e.addChild( XMLUtil.createElement( 'password', c.password ) );
			x.addChild(e);
		}
		for( u in urls ) {
			var e = Xml.createElement( 'url' );
			e.set( 'name', u.name );
			e.set( 'url', u.url );
			x.addChild(e);
		}
		return x;
	}
	
	public static function parse( x : Xml ) : Bookmark {
		var b = new Bookmark();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case 'conference' :
				var conf : Conference = cast { jid : e.get('jid'), name : e.get('name'), nick : e.get('nick') };
				var autojoin = e.get('autojoin');
				if( autojoin != null && autojoin == 'true' ) conf.autojoin = true;
				for( c in e.elements() ) {
					switch( c.nodeName ) {
					case 'nick' : conf.nick = c.firstChild().nodeValue;
					case 'password' : conf.password = c.firstChild().nodeValue;
					}
				}
				b.conferences.push( conf );
			case 'url' :
				b.urls.push( { name : e.get('name'), url : e.get('url') } );
			}
		}
		return b;
	}
	
}
