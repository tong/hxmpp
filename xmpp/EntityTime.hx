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
	XEP 202 - EntityTime: http://www.xmpp.org/extensions/xep-0202.html
*/
class EntityTime {
	
	public static var XMLNS(default,null) : String = "urn:xmpp:time";
	
	/**
		 The UTC time according to the responding entity.
		 The format conforms to the dateTime profile specified in XEP-0082 (http://www.xmpp.org/extensions/xep-0082.html)
		 and MUST be expressed in UTC.
	*/
	public var utc : String; // (default,setUTC) : String;
	
	/**
		The entity's numeric time zone offset from UTC.
		The format conforms to the Time Zone Definition (TZD) specified in XEP-0082 (http://www.xmpp.org/extensions/xep-0082.html).
		Example: +02:00
	*/
	public var tzo : String;// (default,setTZO) : String;
	
	
	public function new( ?utc : String, ?tzo : String ) {
		this.utc = utc;
		this.tzo = tzo;
	}
	
/*
	function setTZO( t : String ) : String {
		//if( !xmpp.DateTime.isValid( t ) ) return tzo = null;
		return tzo = t;
	}
	function setUTC( t : String ) : String {
		if( !xmpp.DateTime.isValid( t ) ) return utc = null;
		return utc = t;
	}
	*/
	
	/*
	public function getTime() : Float {
		fromTime();
	}
	*/
	
	public function toXml() : Xml {
		var x = Xml.createElement( "time" );
		x.ns( XMLNS );
		if( utc != null ) x.addChild( XMLUtil.createElement( "utc", utc ) );
		if( tzo != null ) x.addChild( XMLUtil.createElement( "tzo", tzo ) );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.EntityTime {
		var t = new EntityTime();
		for( c in x.elements() ) {
			switch( c.nodeName ) {
			case "tzo" : t.tzo = c.firstChild().nodeValue;
			case "utc" : t.utc = c.firstChild().nodeValue;
			}
		}
		return t;
	}
	
}
