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
	IQ extension used to bind a resource to a stream.
	http://xmpp.org/rfcs/rfc3920.html#bind">RFC3920#bind
*/
class Bind {
	
	public static var XMLNS(default,null) : String = 'urn:ietf:params:xml:ns:xmpp-bind';
	
	public var resource : String;
	public var jid : String;
	
	public function new( ?resource : String, ?jid : String) {
		this.resource = resource;
		this.jid = jid;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( 'bind' );
		x.ns( XMLNS );
		//if( resource != null ) x.addChild( XMLUtil.createElement( "resource", resource ) );
		//if( jid != null ) x.addChild( XMLUtil.createElement( "jid", jid ) );
		x.addField( this, 'jid' );
		x.addField( this, 'resource' );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.Bind {
		var b = new Bind();
		for( e in x.elements() ) {
			var v = e.firstChild().nodeValue;
			switch( e.nodeName ) {
			case "resource" : b.resource = v;
			case "jid" : b.jid = v;
			}
		}
		return b;
	}
	
}
