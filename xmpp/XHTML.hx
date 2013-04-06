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
	XEP 0071 - XHTML-IM: http://xmpp.org/extensions/xep-0071.html
*/
class XHTML {
	
	public static var XMLNS(default,null) : String = xmpp.Packet.PROTOCOL+"/xhtml-im";
	
	static inline var W3NS = "http://www.w3.org/1999/xhtml";
	
	public var body : String;
	
	public function new( body : String ) {
		this.body = body;
	}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS, 'html' );
		x.addChild( Xml.parse( '<body xmlns="'+W3NS+'">'+body+'</body>' ).firstElement() );
		return x;
	}
	
	public static function parse( x : Xml ) : XHTML {
		for( e in x.elementsNamed( "body" ) )
			if( e.get( "xmlns" ) == W3NS )
				return new XHTML( parseBody( e ) );
		return null;
	}
	
	/**
		Extracts/Returns the HTML body from a message packet.
	*/
	public static function fromMessage( m : xmpp.Message ) : String {
		for( p in m.properties )
			if( p.nodeName == "html" && p.get( "xmlns" ) == XMLNS )
				for( x in p.elementsNamed( "body" ) )
					return parseBody( x );
		return null;
	}	
	
	static function parseBody( x : Xml ) : String {
		var s = new StringBuf();
		for( e in x )
			s.add( e.toString() );
		return s.toString();
	}
	
	/**
		Attaches a HTML body to the properties of the given message packet.
	*/
	public static inline function attach( m : xmpp.Message, t : String ) : xmpp.Message {
		m.properties.push( new XHTML( t ).toXml() );
		return m;
	}
	
	/*
	public static inline function create( t : String ) : Xml {
		return new xmpp.XHTML( t ).toXml();
	}
	*/
	
}
