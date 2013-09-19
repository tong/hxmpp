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

class OOB {
	
	public static inline var XMLNS_IQ = 'jabber:iq:oob';
	
	public var url : String;
	public var desc : String;
	
	public function new( ?url : String, ?desc : String ) {
		this.url = url;
		this.desc = desc;
	}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS_IQ, 'storage' );
		x.addChild( XMLUtil.createElement( "url", url ) );
		x.addChild( XMLUtil.createElement( "desc", desc ) );
		return x;
	}
	
	public static function parse( x : Xml ) : OOB {
		var d = new OOB();
		for( e in x.elements() ) {
			var v = e.firstChild().nodeValue;
			switch( e.nodeName ) {
			case "url" : d.url = v;
			case "desc" : d.desc = v;
			}
		}
		return d;
	}
	
}
