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

/**
	<a href="http://www.xmpp.org/extensions/xep-0138.html">XEP-0138: Stream Compression</a>
*/
class Compression {
	
	public static var XMLNS(default,null) : String = Packet.PROTOCOL+'/compress';
	
	/**
	*/
	public static function createXml( methods : Iterable<String> ) : Xml {
		var x = Xml.createElement( "compress" );
		x.ns( XMLNS );
		for( m in methods )
			x.addChild( XMLUtil.createElement( "method", m ) );
		return x;
	}
	
	/**
		Returns an array of compression methods.
		//TODO same method as SASL.parseMechanisms
	*/
	public static function parseMethods( x : Xml ) : Array<String> {
		var a = new Array<String>();
		for( e in x.elements() ) {
			switch(e.nodeName) {
			case "method" : a.push( e.firstChild().nodeValue );
			}
		}
		return a;
	}
	
}
