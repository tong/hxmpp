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
package xmpp.muc;

import xmpp.XMLUtil;
using xmpp.XMLUtil;

class Decline {
	
	public var to : String;
	public var from : String;
	public var reason : String;

	var nodeName : String;
	
	public function new( ?reason : String, ?to : String, ?from : String ) {
		nodeName = "decline";
		this.reason = reason;
		this.to = to;
		this.from = from;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( nodeName );
		if( to != null ) x.set( "to", to );
		if( from != null ) x.set( "from", from );
		x.addField( this, "reason" );
		return x;
	}
	
	public static function parse( x : Xml ) : Decline {
		var r = if( x.firstElement() == null ) null;
		else x.firstElement().firstChild().nodeValue;
		return new Decline( r, x.get('to'), x.get('from') );
	}
	
}
