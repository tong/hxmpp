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
package xmpp.lop;

using xmpp.XMLUtil;

class Submit {
	
	public var id : String; // vm id
	public var code : String;
	
	public function new( id : String, ?code : String ) {
		this.id = id;
		this.code = code;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "submit_job" );
		x.ns( xmpp.LOP.XMLNS );
		x.set( "vm_id", id );
		if( code != null ) x.addChild( Xml.createPCData( code ) );
		return x;
	}
	
	public static function parse( x : Xml ) : Submit {
		return new Submit( x.get( "vm_id" ),
						   ( x.firstChild() != null ) ? x.firstChild().nodeValue : null );
	}
	
}
