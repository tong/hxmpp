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
	XEP 0092 - Software Version: http://www.xmpp.org/extensions/xep-0092.html
*/
class SoftwareVersion {
	
	public static var XMLNS(default,null) : String = "jabber:iq:version";
	
	/** The natural-language name of the software */
	public var name : String;
	
	/** The specific version of the software */
	public var version : String;
	
	/** The operating system of the queried entity */
	public var os : String;
	
	public function new( ?name : String, ?version : String, ?os : String ) {
		this.name = name;
		this.version = version;
		this.os = os;
	}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS );
		if( name != null ) x.addElement( "name", name );
		if( version != null ) x.addElement( "version", version );
		if( os != null ) x.addElement( "os", os );
		return x;
	}
	
	public static inline function parse( x : Xml ) : SoftwareVersion {
		return new SoftwareVersion().reflectElements( x );
		/*
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "name" : s.name = e.firstChild().nodeValue;
			case "version" : s.version = e.firstChild().nodeValue;
			case "os" : s.os = e.firstChild().nodeValue;
			}
		}
		//s.reflectElements( x );
		return s;
		*/
	}
	
}
