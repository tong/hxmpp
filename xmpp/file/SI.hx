/*
 * Copyright (c) 2012, tong, disktree.net
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
package xmpp.file;

class SI {
	
	public static var XMLNS = "http://jabber.org/protocol/si";
	
	public var id : String;
	public var mime : String;
	public var profile : String;
	public var any : Array<Xml>;
	
	public function new( ?id : String, ?mime : String, ?profile : String ) {
		this.id = id;
		this.mime = mime;
		this.profile = profile;
		any = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "si" );
		xmpp.XMLUtil.ns( x, XMLNS );
		if( id != null ) x.set( "id", id );
		if( mime != null ) x.set( "mime", mime );
		if( profile != null ) x.set( "profile", profile );
		for( e in any ) x.addChild( e );
		return x;
	}
	
	public static function parse( x : Xml ) : SI {
		var s = new SI( x.get( "id" ), x.get( "mime-type" ), x.get( "profile" ) );
		for( e in x.elements() ) s.any.push( e );
		return s;
	}
	
}
