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
package xmpp.file;

class File {
	
	public static inline var XMLNS = SI.XMLNS+"/profile/file-transfer";
	
	public var name : String;
	public var size : Null<Int>;
	public var date : String;
	public var hash : String;
	public var desc : String;
	public var range : Range;
	
	public function new( name : String, size : Null<Int>,
						 ?date : String, ?hash : String, ?desc : String, ?range : Range ) {
		this.name = name;
		this.size = size;
		this.date = date;
		this.hash = hash;
		this.desc = desc;
		this.range = range;
	}

	public function toXml() : Xml {
		var x = Xml.createElement( "file" );
		XMLUtil.ns( x, XMLNS );
		if( name != null ) x.set( "name", name );
		if( size != null ) x.set( "size", Std.string( size ) );
		if( date != null ) x.set( "date", date );
		if( hash != null ) x.set( "hash", hash );
		if( desc != null ) x.addChild( xmpp.XMLUtil.createElement( "desc", desc ) );
		if( range != null ) {
			var r = Xml.createElement( "range" );
			if( range.offset != null ) r.set( "offset", Std.string( range.offset ) );
			if( range.length != null ) r.set( "length", Std.string( range.length ) );
			x.addChild( r );
		}
		return x;
	}
	
	public static function parse( x : Xml ) : File {
		var desc : String = null;
		var range : Range = null;
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "desc" : desc = e.firstChild().nodeValue;
			case "range" :
				range = { offset : null, length : null };
				if( e.exists( "offset" ) ) range.offset = Std.parseInt( e.get( "offset" ) );
				if( e.exists( "length" ) ) range.length = Std.parseInt( e.get( "length" ) );
			}
		}
		return new File( x.get( "name" ), Std.parseInt( x.get( "size" ) ), x.get( "date" ), x.get( "hash" ), desc, range );
	}
	
}
