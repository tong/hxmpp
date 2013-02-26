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
	XEP-0012: Last Activity: http://xmpp.org/extensions/xep-0012.html
*/
class LastActivity {
	
	public static var XMLNS(default,null) : String = "jabber:iq:last";
	
	public var seconds : Int;
	
	public function new( ?seconds : Int = -1 ) {
		this.seconds = seconds;
	}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS );
		if( seconds >= 0 ) x.set( "seconds", Std.string( seconds ) );
		return x;
	}
	
	public static inline function parse( x : Xml ) : LastActivity {
		return new LastActivity( parseSeconds( x ) );
	}
	
	/**
		Parses/Returns the time value of the given IQ query xml.
	*/
	public static inline function parseSeconds( x : Xml ) : Int {
		return Std.parseInt( x.get( "seconds" ) );
	}
	
}
